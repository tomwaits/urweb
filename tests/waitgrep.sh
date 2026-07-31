#!/usr/bin/env bash
# waitgrep.sh FILE PATTERN [TIMEOUT_SECONDS] -- block until FILE exists AND
# contains PATTERN, then exit 0.  Exit 1 LOUDLY otherwise.
#
# The third member of the readiness family, for the case waitport.sh cannot
# serve: when the thing a test is about to assert on is not "a port is open"
# but "the process got far enough to write X".
#
# The daemon check is exactly that case, and it is why this script exists.
# `http.c` binds and listens BEFORE it forks the daemon child (bind -> listen ->
# fork -> uw_request_init, which is what finally spawns the app's `task
# periodic` thread).  So by the time `daemon.exe -d` returns, the port is
# ALREADY accepting -- a waitport probe there returns instantly and cannot fail,
# and the assertions that follow it (`test -s $(TESTDLOG)`, `grep -q
# PERIODIC_FIRED`) were left racing against the fork with only the cost of
# spawning this script to protect them.  Sampling at that instant found the log
# still empty 2 of 8 times and the marker absent 4 of 8.  A poll on the port is
# a check that cannot fail; a poll on the marker is the real precondition.
set -euo pipefail

target="${1:?usage: waitgrep.sh FILE PATTERN [TIMEOUT_SECONDS]}"
pattern="${2:?usage: waitgrep.sh FILE PATTERN [TIMEOUT_SECONDS]}"
timeout="${3:-20}"

case "$timeout" in
    ''|*[!0-9]*)
        echo "waitgrep: TIMEOUT_SECONDS must be a non-negative integer, got '$timeout'" >&2
        exit 2 ;;
esac

deadline=$(( $(date +%s) + timeout + 1 ))

until [ -e "$target" ] && grep -q -- "$pattern" "$target" 2>/dev/null; do
    if [ "$(date +%s)" -ge "$deadline" ]; then
        if [ -e "$target" ]; then
            echo "waitgrep: FAILED -- '$pattern' never appeared in $target after ${timeout}s." >&2
            echo "The file exists, so the process started but did not reach the point" >&2
            echo "that writes that marker." >&2
        else
            echo "waitgrep: FAILED -- $target never appeared after ${timeout}s." >&2
            echo "The process that should have created it never came up: a STARTUP" >&2
            echo "failure, not a behavioural one." >&2
        fi
        exit 1
    fi
    sleep 0.1
done
