#!/usr/bin/env bash
# has-ipv6-loopback.sh -- report whether this machine has a usable IPv6 loopback.
#   exit 0  ::1 is configured
#   exit 1  IPv6 loopback is genuinely absent
#   exit 2  CANNOT DETERMINE -- the probe itself is unavailable or failed
# Always says WHY on stderr.
#
# `make test` used to gate its IPv6 checks on:
#
#     if (ifconfig lo | grep -q inet6); then ... else echo "Skipped IPv6 tests."
#
# which conflates two very different situations.  `ifconfig` ships in net-tools,
# which is DEPRECATED and absent from modern distributions and CI runner images.
# On such a machine the condition fails not because IPv6 is missing but because
# the probe is missing -- and the suite printed a calm "Skipped IPv6 tests." and
# moved on.  The IPv6 checks had therefore been skipping on every CI run while
# looking like a deliberate skip.
#
# A check that cannot fail is not a check.  So the exit-2 case is kept strictly
# separate from exit 1 all the way through: every branch below distinguishes
# "the probe answered NO" from "the probe could not answer", including the
# failure modes of the probes themselves (an unreadable /proc file, a grep that
# errored rather than not-matched, an ifconfig that could not read the
# interface).  Collapsing those is the original bug, and it would be easy to
# reintroduce one layer down.
#
# NB no `set -e`: every command's status is consumed by an `if`, and errexit
# would abort on the first non-matching probe.  No `pipefail` either -- with
# `grep -q` (which exits at the first match and SIGPIPEs the writer) it can turn
# a successful MATCH into a failed pipeline, i.e. a false "IPv6 absent".
set -u

# 1. Linux kernel interface: one line per configured IPv6 address, the address
#    written as 32 hex digits with no colons, so ::1 is 31 zeros then a 1.
if [ -e /proc/net/if_inet6 ]; then
    if [ ! -r /proc/net/if_inet6 ]; then
        echo "has-ipv6-loopback: /proc/net/if_inet6 exists but is not readable -- cannot determine" >&2
        exit 2
    fi
    grep -qE '^0{31}1 ' /proc/net/if_inet6
    g=$?
    if [ "$g" -eq 0 ]; then
        echo "has-ipv6-loopback: ::1 is configured (/proc/net/if_inet6)" >&2
        exit 0
    elif [ "$g" -gt 1 ]; then
        echo "has-ipv6-loopback: grep FAILED (status $g) reading /proc/net/if_inet6 -- cannot determine" >&2
        exit 2
    fi
    echo "has-ipv6-loopback: no ::1 in /proc/net/if_inet6 -- IPv6 loopback is not configured" >&2
    exit 1
fi

# 2. iproute2 -- the modern replacement for net-tools. `lo0` covers the BSD/macOS
#    spelling; a failure to read EITHER interface is "cannot determine", never
#    "absent", which is the distinction this script exists to preserve.
if command -v ip >/dev/null 2>&1; then
    for dev in lo lo0; do
        if out=$(ip -6 addr show "$dev" 2>/dev/null); then
            if printf '%s\n' "$out" | grep -q 'inet6 ::1'; then
                echo "has-ipv6-loopback: ::1 is configured (ip -6 addr show $dev)" >&2
                exit 0
            fi
            echo "has-ipv6-loopback: 'ip -6 addr show $dev' reports no ::1 -- IPv6 loopback is not configured" >&2
            exit 1
        fi
    done
    echo "has-ipv6-loopback: 'ip' could not read interface lo or lo0 -- cannot determine" >&2
    exit 2
fi

# 3. net-tools, for older systems that still have it.
if command -v ifconfig >/dev/null 2>&1; then
    for dev in lo lo0; do
        if out=$(ifconfig "$dev" 2>/dev/null); then
            if printf '%s\n' "$out" | grep -q inet6; then
                echo "has-ipv6-loopback: ::1 is configured (ifconfig $dev)" >&2
                exit 0
            fi
            echo "has-ipv6-loopback: 'ifconfig $dev' reports no inet6 -- IPv6 loopback is not configured" >&2
            exit 1
        fi
    done
    echo "has-ipv6-loopback: 'ifconfig' could not read interface lo or lo0 -- cannot determine" >&2
    exit 2
fi

echo "has-ipv6-loopback: CANNOT DETERMINE -- no /proc/net/if_inet6, no 'ip', no 'ifconfig'." >&2
echo "This is not the same as 'IPv6 is unavailable': the PROBE is unavailable." >&2
echo "Treat it as an untested configuration, not a clean skip." >&2
exit 2
