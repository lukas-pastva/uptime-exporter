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

# usage: UPTIME_PERCENTAGE_SUM=$(calculate_uptime_percentage "$m" "$i" "$UPTIME_PERCENTAGE_SUM" "$END_TIME" "$STEP")
calculate_uptime_percentage() {
    m=$1
    i=$2
    UPTIME_PERCENTAGE_SUM=$3
    END_TIME=$4
    STEP=$5
    START_TIME=$((END_TIME-STEP))
    MEASURE_START_UNIX=$6

    #if [ $MEASURE_START_UNIX -ge $START_TIME ] && [ $MEASURE_START_UNIX -le $END_TIME ]; then
    if [ $MEASURE_START_UNIX -ge $END_TIME ]; then
        echo "100"
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

      UPTIME_PERCENTAGE_QUERY=$(echo "scale=5; $UPTIME_PERCENTAGE_QUERY" | bc)
      UPTIME_PERCENTAGE_SUM=$(echo "$UPTIME_PERCENTAGE_SUM" + "$UPTIME_PERCENTAGE_QUERY" | bc)
      echo "${UPTIME_PERCENTAGE_SUM}"
    fi
}

EPOCH=$(date +%s)
export PROMETHEUS_URL=$(yq e '.config.prometheus_url' /home/config.yaml)
