#!/bin/bash

unreachable_peers=$(
  /usr/sbin/asterisk -rvx 'sip show peers' 2>/dev/null |
  awk '
    /^[[:alnum:]_.-]+(\/[^[:space:]]+)?[[:space:]]/ && $1 ~ /[A-Za-z]/ && /UNREACHABLE/ {
      print
    }
  '
)

unreachable_check=$(printf '%s\n' "$unreachable_peers" | grep -c .)

if [ "${unreachable_check}" -gt "0" ]; then
        echo "Status: NOK, provider peers unreachable: ${unreachable_check}"
        printf '%s\n' "$unreachable_peers"
        exit 2
else
        echo "Status: OK, all provider peers reachable."
        exit 0
fi
