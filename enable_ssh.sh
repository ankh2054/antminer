#!/usr/bin/env bash

# Add all IPs for miners in ips.txt

IPS=$(cat ips.txt)

for ip in $IPS; do
	echo
	if [[ -e "/usr/bin/compile_time" ]]; then
		curl -s -X POST --digest --user root:root http://$ip/cgi-bin/create_log_backup.cgi -d "/null /config/dropbear -sf"
		sleep 0.5
		curl -s -X GET --digest --user root:root http://$ip/cgi-bin/reboot.cgi &
	else
		curl -s -X POST --digest --user root:root http://$ip/cgi-bin/create_log_backup.cgi -d "/null /config/dropbear -sf"
		sleep 0.5
		curl -s -X GET --digest --user root:root http://$ip/cgi-bin/reboot.cgi &
	fi


	if [[ $? -ne 0 ]]; then
		echo -e "Error connecting"
	else
		echo -e "OK"

	fi

done
