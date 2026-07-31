#!/usr/bin/env bash
# has-ipv6-loopback.sh -- exit 0 if this machine has a usable IPv6 loopback
# (::1), nonzero otherwise.  Always says WHY on stderr.
#
# `make test` used to gate its IPv6 checks on:
#
#     if (ifconfig lo | grep -q inet6); then ... else echo "Skipped IPv6 tests."
#
# which conflates two very different situations.  `ifconfig` ships in net-tools,
# which is DEPRECATED and absent from modern distributions and CI runner images.
# On such a machine the condition fails not because IPv6 is missing but because
# the probe itself is missing -- and the suite prints a calm "Skipped IPv6
# tests." and moves on.  The IPv6 tests had therefore been skipped on every CI
# run while looking like a normal, deliberate skip.
#
# A check that cannot fail is not a check.  So this script:
#   * prefers /proc/net/if_inet6, which needs no external tool at all;
#   * falls back to iproute2 (`ip`), then to ifconfig;
#   * DISTINGUISHES "IPv6 is genuinely absent" (exit 1) from "I could not tell"
#     (exit 2) -- the second is the state that hid the problem, so it gets its
#     own exit code and a loud message rather than being folded into a skip.
set -uo pipefail

# 1. Linux kernel interface: one line per configured IPv6 address, the address
#    written as 32 hex digits with no colons, so ::1 is 31 zeros then a 1.
if [ -r /proc/net/if_inet6 ]; then
    if grep -qE '^0{31}1 ' /proc/net/if_inet6; then
        echo "has-ipv6-loopback: ::1 is configured (/proc/net/if_inet6)" >&2
        exit 0
    fi
    echo "has-ipv6-loopback: no ::1 in /proc/net/if_inet6 -- IPv6 loopback is not configured" >&2
    exit 1
fi

# 2. iproute2 -- the modern replacement for net-tools.
if command -v ip >/dev/null 2>&1; then
    if ip -6 addr show lo 2>/dev/null | grep -q 'inet6 ::1'; then
        echo "has-ipv6-loopback: ::1 is configured (ip -6 addr show lo)" >&2
        exit 0
    fi
    echo "has-ipv6-loopback: 'ip -6 addr show lo' reports no ::1 -- IPv6 loopback is not configured" >&2
    exit 1
fi

# 3. net-tools, for older systems that still have it.
if command -v ifconfig >/dev/null 2>&1; then
    if ifconfig lo 2>/dev/null | grep -q inet6; then
        echo "has-ipv6-loopback: ::1 is configured (ifconfig lo)" >&2
        exit 0
    fi
    echo "has-ipv6-loopback: 'ifconfig lo' reports no inet6 -- IPv6 loopback is not configured" >&2
    exit 1
fi

echo "has-ipv6-loopback: CANNOT DETERMINE -- no /proc/net/if_inet6, no 'ip', no 'ifconfig'." >&2
echo "This is not the same as 'IPv6 is unavailable': the PROBE is unavailable." >&2
echo "Treat it as an untested configuration, not a clean skip." >&2
exit 2
