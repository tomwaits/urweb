#!/usr/bin/env bash
# waitport.sh HOST PORT [TIMEOUT_SECONDS] -- block until something accepts a TCP
# connection on HOST:PORT, then exit 0.  Exit 1 LOUDLY if nothing does in time.
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
# Failing loudly matters as much as waiting.  A swallowed startup failure turns
# the serve+curl assertion that follows it vacuous, which is the class of bug
# the liveness gates (`kill -0`) elsewhere in this suite exist to catch.
set -euo pipefail

host="${1:?usage: waitport.sh HOST PORT [TIMEOUT_SECONDS]}"
port="${2:?usage: waitport.sh HOST PORT [TIMEOUT_SECONDS]}"
timeout="${3:-20}"

deadline=$(( $(date +%s) + timeout ))

# The probe runs in a subshell so the descriptor is closed for us on exit; bash
# resolves a bracketless IPv6 literal here, so `waitport.sh ::1 8080` works.
until (exec 3<>"/dev/tcp/$host/$port") 2>/dev/null; do
    if [ "$(date +%s)" -ge "$deadline" ]; then
        echo "waitport: FAILED -- nothing accepting on $host:$port after ${timeout}s." >&2
        echo "The server under test never bound its port, so this is a STARTUP" >&2
        echo "failure, not a content failure.  Check for a stale process holding" >&2
        echo "that port from an aborted run." >&2
        exit 1
    fi
    sleep 0.1
done
