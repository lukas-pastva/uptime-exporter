#!/bin/bash
#set -e

function echo_message {
  echo -e "\n# $1"
}

metric_add(){
  RESULT=$1
  RESULTS=$2

  echo -e "$RESULTS\n$RESULT"
}

# usage: DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
calculate_downtime_seconds_from_percentage() {
    UPTIME_PERCENTAGE=$1
    START_TIME=$2
    END_TIME=$3

    TOTAL_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
    UPTIME_SECONDS=$(echo "scale=5; ($UPTIME_PERCENTAGE/100)*$TOTAL_TIME" | bc -l)
    DOWNTIME_SECONDS=$(echo "$TOTAL_TIME - $UPTIME_SECONDS" | bc -l)

    echo "${DOWNTIME_SECONDS}"
}

# usage: UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP")
calculate_uptime_percentage() {
    m=$1
    i=$2
    END_TIME=$3
    STEP=$4
    START_TIME=$((END_TIME-STEP))
    MEASURE_START_UNIX=$5

    # if we are in middle of measurement, we need to change the start time, eg change step
    if [ $MEASURE_START_UNIX -ge $START_TIME ] && [ $MEASURE_START_UNIX -le $END_TIME ]; then
      # calculating variables
      NON_LIVE_TIME=$((MEASURE_START_UNIX-START_TIME))
      PERCENTAGE_NON_LIVE=$(echo "scale=10;$NON_LIVE_TIME / $STEP * 100" | bc)
      LIVE_TIME=$((END_TIME-MEASURE_START_UNIX))
      PERCENTAGE_LIVE=$(echo "scale=10;$LIVE_TIME / $STEP * 100" | bc)

      STEP=$((STEP-NON_LIVE_TIME))
    fi

    # if we are before live/measurementStart, needs to be 100%
    if [ $MEASURE_START_UNIX -ge $END_TIME ]; then
      RESULT_PERCENTAGE="100"
    else
      QUERY_TYPE=$(yq e ".config.metrics[$m].queries[$i].queryType" /home/config.yaml)

      if [ "${QUERY_TYPE}" == "kube_deployment_status_replicas" ]; then
        CLUSTER=$(yq e ".config.metrics[$m].queries[$i].cluster" /home/config.yaml)
        NAMESPACE=$(yq e ".config.metrics[$m].queries[$i].namespace" /home/config.yaml)
        DEPLOYMENT=$(yq e ".config.metrics[$m].queries[$i].name" /home/config.yaml)

        UPTIME_PERCENTAGE_QUERY=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\",namespace=\"$NAMESPACE\",deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\",namespace=\"$NAMESPACE\",deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
      fi

      if [ "${QUERY_TYPE}" == "probe_success" ]; then
        CLUSTER=$(yq e ".config.metrics[$m].queries[$i].cluster" /home/config.yaml)
        INSTANCE=$(yq e ".config.metrics[$m].queries[$i].instance" /home/config.yaml)

        UPTIME_PERCENTAGE_QUERY=$(curl -s -G --data-urlencode "query=avg_over_time(probe_success{cluster=\"$CLUSTER\",instance=\"$INSTANCE\"}[1h]) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
      fi

      RESULT_PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_QUERY" | bc)
    fi

    # if we are in middle of measurement, we need to add the percentage of uptime
    if [ $MEASURE_START_UNIX -ge $START_TIME ] && [ $MEASURE_START_UNIX -le $END_TIME ]; then
      # the RESULT_PERCENTAGE is corresponding only for the time after measurementStart
      # we need to calculate that with regards to total PERCENTAGE_LIVE
      RESULT_PERCENTAGE_LIVE=$(echo "scale=10;$RESULT_PERCENTAGE * $PERCENTAGE_LIVE / 100" | bc)
      RESULT_PERCENTAGE=$(echo "scale=5;$RESULT_PERCENTAGE_LIVE + $PERCENTAGE_NON_LIVE" | bc)
    fi

    echo $RESULT_PERCENTAGE
}

EPOCH=$(date +%s)
export PROMETHEUS_URL=$(yq e '.config.prometheus_url' /home/config.yaml)
