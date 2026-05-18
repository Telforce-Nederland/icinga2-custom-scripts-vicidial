#!/bin/bash

vicidial_live_agents=$(mysql -u cron -p1234 asterisk -N -s -e "
SELECT COUNT(*)
FROM vicidial_live_agents
WHERE extension IS NULL
   OR extension NOT LIKE 'R/%';
")

echo "Aantal live agents: ${vicidial_live_agents} | live_agents=${vicidial_live_agents};;;0;"

exit 0
