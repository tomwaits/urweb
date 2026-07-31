#!/usr/bin/env bash
# waitport.sh HOST PORT [TIMEOUT_SECONDS] [PID] -- block until something accepts
# a TCP connection on HOST:PORT, then exit 0.  Exit 1 LOUDLY if nothing does.
#
# Replaces the fixed `sleep 1` that preceded every serve+curl check in
# `make test`.  A fixed sleep is wrong in both directions:
#
#   * On a loaded machine (CI runners, parallel builds) one second is not always
#     enough.  The server has not bound yet, curl gets connection-refused, and
#     the check reports a CONTENT failure -- "viewBox attribute not rendered" --
#     for what is really a TIMING failure.  That is the most misleading way a
#     test can fail, and it trains people to re-run rather than investigate.
#   * When the server is ready in milliseconds (the normal case) it burns a
#     whole second per test for nothing.
#
# PID (optional, strongly recommended) is the pid of the server we just
# launched.  Without it this script waits for *anything* to accept on the port,
# which is satisfied instantly by a STALE survivor from an aborted run -- so the
# poll would hand a green light to a test about to assert against the wrong
# process.  Given PID, a dead server is caught immediately and named as such,
# which is both faster and honest.  Measured: the real exe loses its bind and
# exits in 2-4ms, so without this check the race is genuinely losable.
#
# Failing loudly matters as much as waiting, and failing ACCURATELY matters as
# much as failing loudly: the timeout branch reports the probe's own error
# rather than asserting a cause it did not observe.  A script that blames "the
# server never bound" when the truth is "this bash has no /dev/tcp" would
# recreate, one level up, the exact confusion it exists to remove.
set -euo pipefail

host="${1:?usage: waitport.sh HOST PORT [TIMEOUT_SECONDS] [PID]}"
port="${2:?usage: waitport.sh HOST PORT [TIMEOUT_SECONDS] [PID]}"
timeout="${3:-20}"
pid="${4:-}"

case "$timeout" in
    ''|*[!0-9]*)
        echo "waitport: TIMEOUT_SECONDS must be a non-negative integer, got '$timeout'" >&2
        exit 2 ;;
esac

# +1 because the whole-second comparison below otherwise truncates the budget to
# (timeout-1, timeout].
deadline=$(( $(date +%s) + timeout + 1 ))
err=""

# The probe runs in a subshell so the descriptor is closed for us on exit; bash
# resolves a bracketless IPv6 literal here, so `waitport.sh ::1 8080` works.
until err="$( (exec 3<>"/dev/tcp/$host/$port") 2>&1 )"; do
    if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
        echo "waitport: FAILED -- the server we launched (pid $pid) is already gone;" >&2
        echo "it never bound $host:$port.  This is a STARTUP failure, not a content" >&2
        echo "failure.  Most likely a stale process from an aborted run still holds" >&2
        echo "that port, so the fresh server could not bind." >&2
        exit 1
    fi
    if [ "$(date +%s)" -ge "$deadline" ]; then
        echo "waitport: FAILED -- nothing accepting on $host:$port after ${timeout}s." >&2
        echo "last probe error: ${err:-(none reported)}" >&2
        case "$err" in
            *"No such file or directory"*)
                echo "NOTE: that error means this bash has no /dev/tcp support" >&2
                echo "(built --disable-net-redirections), NOT that the server is down." >&2 ;;
            *)
                echo "If the probe error above names the server rather than the probe," >&2
                echo "this is a STARTUP failure: check for a stale process on that port." >&2 ;;
        esac
        exit 1
    fi
    sleep 0.1
done
