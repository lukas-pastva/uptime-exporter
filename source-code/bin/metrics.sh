#!/bin/bash
export $(xargs -0 -a "/proc/1/environ") 2>/dev/null

source functions.inc.sh

query='up{job="your_job_name"}[30d]'
response=$(curl -sG --data-urlencode "query=$query" "${PROMETHEUS_URL}")
uptime_values=$(echo "$response" | grep -oE '\[[0-9]+.[0-9]+\]')

echo "$uptime_values"
