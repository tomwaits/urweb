#!/usr/bin/env bash
# waitfile.sh PATH [TIMEOUT_SECONDS] -- block until PATH exists, then exit 0.
# Exit 1 LOUDLY if it never appears.
#
# The companion to waitport.sh for the one server in `make test` that does not
# listen on a TCP port: the compile daemon binds a unix socket (.urweb_daemon)
# in its working directory, so there is no port to probe.  Same rationale --
# a fixed `sleep 1` either races on a loaded machine or wastes a second, and a
# silently-missed startup makes every assertion after it vacuous.
set -euo pipefail

target="${1:?usage: waitfile.sh PATH [TIMEOUT_SECONDS]}"
timeout="${2:-20}"

deadline=$(( $(date +%s) + timeout ))

until [ -e "$target" ]; do
    if [ "$(date +%s)" -ge "$deadline" ]; then
        echo "waitfile: FAILED -- $target did not appear after ${timeout}s." >&2
        echo "The process that should have created it never came up, so this is" >&2
        echo "a STARTUP failure, not a behavioural one." >&2
        exit 1
    fi
    sleep 0.1
done
