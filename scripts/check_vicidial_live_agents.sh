#!/bin/bash

vicidial_live_agents=$(mysql -u cron -p1234 asterisk -N -s -e 'select count(*) from vicidial_live_agents')

echo "Aantal live agents: ${vicidial_live_agents} | live_agents=${vicidial_live_agents};;;0;"

exit 0
