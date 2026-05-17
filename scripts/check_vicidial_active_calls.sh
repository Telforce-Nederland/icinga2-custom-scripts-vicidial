#!/bin/bash

# check_vicidial_active_calls.sh
# Telt actieve Vicidial gesprekken op basis van vicidial_auto_calls.
#
# Metrics:
# - inbound  = status CLOSER
# - outbound = status XFER
# - waiting  = status LIVE
# - total    = CLOSER + XFER + LIVE
#
# MySQL user: cron
# MySQL pass: 1234
# Database:   asterisk

MYSQL_USER="cron"
MYSQL_PASS="1234"
MYSQL_DB="asterisk"

MYSQL_BIN="/usr/bin/mysql"

if [ ! -x "$MYSQL_BIN" ]; then
    echo "UNKNOWN - mysql client not found at $MYSQL_BIN"
    exit 3
fi

RESULT=$($MYSQL_BIN \
    --batch \
    --skip-column-names \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASS" \
    "$MYSQL_DB" \
    -e "
SELECT
  COALESCE(SUM(status = 'CLOSER'), 0) AS inbound,
  COALESCE(SUM(status = 'XFER'), 0) AS outbound,
  COALESCE(SUM(status = 'LIVE'), 0) AS waiting,
  COALESCE(SUM(status IN ('CLOSER','XFER','LIVE')), 0) AS total
FROM vicidial_auto_calls;
" 2>/tmp/check_vicidial_active_calls.err)

MYSQL_EXIT=$?

if [ "$MYSQL_EXIT" -ne 0 ]; then
    ERROR_MSG=$(cat /tmp/check_vicidial_active_calls.err 2>/dev/null)
    echo "UNKNOWN - MySQL query failed: $ERROR_MSG"
    exit 3
fi

read -r INBOUND OUTBOUND WAITING TOTAL <<< "$RESULT"

# Fallback als waarden leeg zijn
INBOUND=${INBOUND:-0}
OUTBOUND=${OUTBOUND:-0}
WAITING=${WAITING:-0}
TOTAL=${TOTAL:-0}

echo "Active calls total: $TOTAL inbound=$INBOUND outbound=$OUTBOUND waiting=$WAITING | total=$TOTAL;;;0; inbound=$INBOUND;;;0; outbound=$OUTBOUND;;;0; waiting=$WAITING;;;0;"

exit 0
