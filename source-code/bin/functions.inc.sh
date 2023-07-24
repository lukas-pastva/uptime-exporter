#!/bin/bash
#set -e

function echo_message {
  echo -e "\n# $1"
}

calculate_downtime_seconds_from_percentage() {
    UPTIME_PERCENTAGE=$1
    START_TIME=$2
    END_TIME=$3

    TOTAL_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
    UPTIME_SECONDS=$(echo "scale=5; ($UPTIME_PERCENTAGE/100)*$TOTAL_TIME" | bc -l)
    DOWNTIME_SECONDS=$(echo "$TOTAL_TIME - $UPTIME_SECONDS" | bc -l)

    # echo "total time: $((TOTAL_TIME))"
    # echo "Uptime Seconds: $UPTIME_SECONDS"
    # echo "Downtime Seconds: $DOWNTIME_SECONDS"
    echo "${DOWNTIME_SECONDS}"
}

export PROMETHEUS_URL=$(yq e '.config.prometheus_url' /home/config.yaml)
export NAMESPACE=$(yq e '.config.namespace' /home/config.yaml)
