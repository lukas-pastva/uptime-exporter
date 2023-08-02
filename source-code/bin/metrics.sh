#!/bin/bash
export $(xargs -0 -a "/proc/1/environ") 2>/dev/null

source functions.inc.sh

EPOCH=$(date +%s)
RESULT="uptime_exporter_heart_beat ${EPOCH}"
RESULTS=$(echo -e "$RESULTS\n$RESULT")

# iterate over metrics
METRICS_COUNT=$(yq e '.config.metrics | length' /home/config.yaml)
for ((m=0; m<$METRICS_COUNT; m++)); do
  METRIC=$(yq e ".config.metrics[$m].name" /home/config.yaml)
  DEPLOYMENT_COUNT=$(yq e ".config.metrics[$m].deployments | length" /home/config.yaml)


  # IN last XXX
  # uptime in last 7 days
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*7))
  for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
    CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
    NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
    DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

    UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
  done
  RESULT="uptime_exporter_in_last_7_days{metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
  RESULTS=$(echo -e "$RESULTS\n$RESULT")

  # uptime in last 30 days
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*30))
  for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
    CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
    NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
    DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

    UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
  done
  RESULT="uptime_exporter_in_last_30_days{metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
  RESULTS=$(echo -e "$RESULTS\n$RESULT")

  # uptime in previous month
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -d "$(date +%Y-%m-01) -1 second" +%s)
  STEP=$((3600*24*30))
  for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
    CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
    NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
    DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

    UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
  done
  RESULT="uptime_exporter_in_previous_month{metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
  RESULTS=$(echo -e "$RESULTS\n$RESULT")

  # uptime in three months ago
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*90))
  for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
    CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
    NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
    DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

    UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
  done
  RESULT="uptime_exporter_in_three_months_ago{metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
  RESULTS=$(echo -e "$RESULTS\n$RESULT")

  # uptime in this year
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*$(date +%j)))
  for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
    CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
    NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
    DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

    UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
  done
  RESULT="uptime_exporter_in_this_year{metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
  RESULTS=$(echo -e "$RESULTS\n$RESULT")

  # uptime in one year ago
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*365))
  for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
    CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
    NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
    DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

    UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
  done
  RESULT="uptime_exporter_in_one_year_ago{metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
  RESULTS=$(echo -e "$RESULTS\n$RESULT")

  # uptime in two years ago
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -d "1 year ago" +%s)
  STEP=$((3600*24*365))
  for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
    CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
    NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
    DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

    UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
  done
  RESULT="uptime_exporter_in_two_years_ago{metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
  RESULTS=$(echo -e "$RESULTS\n$RESULT")



  # PER last XXX
  # uptime per last 12 months
  for j in {0..11}; do
    UPTIME_PERCENTAGE_SUM=0
    END_TIME=$(date -d"$j month ago $(date +%T)" +%s)
    STEP=$((3600*24*30))
    for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
      CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
      NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
      DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

      UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
      UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
    done
    RESULT="uptime_exporter_per_last_12_months{month_in_past=\"$(date -d "@$END_TIME" '+%Y-%m')\", metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
    RESULTS=$(echo -e "$RESULTS\n$RESULT")
  done

  # uptime per last 4 weeks
  for j in {0..3}; do
    UPTIME_PERCENTAGE_SUM=0
    END_TIME=$(date -d"$j week ago $(date +%T)" +%s)
    STEP=$((3600*24*7))
    for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
      CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
      NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
      DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

      UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
      UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
    done
    RESULT="uptime_exporter_per_last_4_weeks{week_in_past=\"week nr. $(date -d "@$END_TIME" '+%V')\", metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
    RESULTS=$(echo -e "$RESULTS\n$RESULT")
  done

  # uptime per last 7 days
  for j in {0..6}; do
    UPTIME_PERCENTAGE_SUM=0
    END_TIME=$(date -d"$j day ago $(date +%T)" +%s)
    STEP=$((3600*24))
    for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
      CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
      NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
      DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

      UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
      UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
    done
    RESULT="uptime_exporter_per_last_7_days{day_in_past=\"$(date -d "@$END_TIME" '+%Y-%m-%d')\", metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
    RESULTS=$(echo -e "$RESULTS\n$RESULT")
  done


  # uptime per last 24 hours
  for j in {0..24}; do
    UPTIME_PERCENTAGE_SUM=0
    END_TIME=$(date -d "-$j hours" +%s)
    STEP=3600
    for ((i=0; i<$DEPLOYMENT_COUNT; i++)); do
      CLUSTER=$(yq e ".config.metrics[$m].deployments[$i].cluster" /home/config.yaml)
      NAMESPACE=$(yq e ".config.metrics[$m].deployments[$i].namespace" /home/config.yaml)
      DEPLOYMENT=$(yq e ".config.metrics[$m].deployments[$i].name" /home/config.yaml)

      UPTIME_PERCENTAGE_DEPLOYMENT=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{cluster=\"$CLUSTER\", namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
      UPTIME_PERCENTAGE_SUM=$((UPTIME_PERCENTAGE_SUM + UPTIME_PERCENTAGE_DEPLOYMENT))
    done
    RESULT="uptime_exporter_per_last_24_hours{hour_in_past=\"$(date -d "@$END_TIME" '+%Y-%m-%d %H')\", metric=\"${METRIC}\"} $(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)"
    RESULTS=$(echo -e "$RESULTS\n$RESULT")
  done


done

# metric for time taken to scrape
RESULT="uptime_exporter_scrape_time $(($(date +%s)-EPOCH))"
RESULTS=$(echo -e "$RESULTS\n$RESULT")

echo -e "$RESULTS" > /tmp/metrics.log