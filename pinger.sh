#!/bin/sh

cd "$(dirname "$0")"

export TZ=America/Los_Angeles

LOGFILE="pinger.log"

touch "${LOGFILE}"

ts() {
	INPUT=$(cat)
	echo "${INPUT}" | while IFS= read -r line; do
		echo "${line}" | perl -pe 'use POSIX strftime; print strftime "[%Y-%m-%d %H:%M:%S] ", localtime'
	done
}

echo "Started" | ts >>"${LOGFILE}"

trap ctrl_c INT
ctrl_c() {
	echo "Stopped" | ts >>"${LOGFILE}"
	exit 130
}

while true; do
	RESULTS=$(ping -W 1 -c 1 8.8.8.8 || true)
	REGEXP='^.*?([0-9]+)\s(packets\s)?received.*$'
	RECEIVED_LINE=$(echo "${RESULTS}" | grep -E "${REGEXP}")
	echo "${RECEIVED_LINE}" | ts
	RECEIVED=$(echo "${RECEIVED_LINE}" | sed -E "s/${REGEXP}/\1/")
	if [ "${RECEIVED}" != "1" ]; then
		echo "ERROR!!" | ts
		echo "${RECEIVED_LINE}" | ts >>"${LOGFILE}"
	fi
	sleep 1
done
