#!/bin/bash
export $(xargs -0 -a "/proc/1/environ") 2>/dev/null

source functions.inc.sh

export EPOCH=$(date +%s)
METRIC="uptime_exporter_heart_beat ${EPOCH}"
METRICS=$(echo -e "$METRICS\n$METRIC")

# iterate over Prometheus jobs
DEPLOYMENTS=$(curl -G "$PROMETHEUS_URL/api/v1/query" --data-urlencode 'query=kube_deployment_status_replicas_updated' | jq -r ".data.result[] | select(.metric.namespace==\"$NAMESPACE\") | .metric.deployment")
for DEPLOYMENT in $DEPLOYMENTS; do

  # PER last XXX
  # uptime per last 24 hours
  for i in {0..24}; do
    END_TIME=$(date -d "-$i hours" +%s)
    STEP=3600
    UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
    METRIC="uptime_exporter_per_last_24_hours{hour_in_past=\"$(date -d "@$END_TIME" '+%Y-%m-%d %H')\",prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
    METRICS=$(echo -e "$METRICS\n$METRIC")
  done

  # PER last XXX
  # uptime per last 10 days
  for i in {0..9}; do
    END_TIME=$(date -d"$i day ago $(date +%T)" +%s)
    STEP=$((3600*24))
    UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
    METRIC="uptime_exporter_per_last_10_days{day_in_past=\"$(date -d "@$END_TIME" '+%Y-%m-%d')\",prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
    METRICS=$(echo -e "$METRICS\n$METRIC")
  done

  # uptime per last 10 weeks
  for i in {0..9}; do
    # start_time=$(date -d"$i week ago 00:00:00" +%s)
    END_TIME=$(date -d"$i week ago $(date +%T)" +%s)
    STEP=$((3600*24*7))
    UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
    METRIC="uptime_exporter_per_last_10_weeks{week_in_past=\"week nr. $(date -d "@$END_TIME" '+%V')\",prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
    METRICS=$(echo -e "$METRICS\n$METRIC")
  done

  # uptime per last 12 months
  for i in {0..11}; do
    # start_time=$(date -d"$i month ago 00:00:00" +%s)
    END_TIME=$(date -d"$i month ago $(date +%T)" +%s)
    STEP=$((3600*24*30))
    UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
    METRIC="uptime_exporter_per_last_12_months{month_in_past=\"$(date -d "@$END_TIME" '+%Y-%m')\",prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
    METRICS=$(echo -e "$METRICS\n$METRIC")
  done


  # IN last XXX
  # uptime in last 7 days
  # start_time=$(date -d "7 day ago" -u +%s)
  END_TIME=$(date -u +%s)
  start_time=$((END_TIME-60))
  STEP=$((3600*24*30))
  UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
  METRIC="uptime_exporter_in_last_7_days{prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in last 30 days
  # start_time=$(date -d "30 day ago" -u +%s)
  END_TIME=$(date -u +%s)
  start_time=$((END_TIME-60))
  STEP=$((3600*24*30))
  UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
  METRIC="uptime_exporter_in_last_30_days{prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in previous month
  # start_time=$(date -d "$(date +%Y-%m-01) -1 month" +%s)
  END_TIME=$(date -d "$(date +%Y-%m-01) -1 second" +%s)
  start_time=$((END_TIME-60))
  STEP=$((3600*24*30))
  UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
  METRIC="uptime_exporter_in_previous_month{prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in three months ago
  # start_time=$(date -d "3 months ago" +%s)
  END_TIME=$(date -u +%s)
  start_time=$((END_TIME-60))
  STEP=$((3600*24*90))
  UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
  METRIC="uptime_exporter_in_three_months_ago{prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in this year
  # start_time=$(date -d "$(date +%Y)-01-01 00:00:00" +%s)
  END_TIME=$(date -u +%s)
  start_time=$((END_TIME-60))
  STEP=$((3600*24*$(date +%j)))
  UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
  METRIC="uptime_exporter_in_this_year{prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in one year ago
  # start_time=$(date -d "1 year ago" +%s)
  END_TIME=$(date -u +%s)
  start_time=$((END_TIME-60))
  STEP=$((3600*24*365))
  UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
  METRIC="uptime_exporter_in_one_year_ago{prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in two years ago
  # start_time=$(date -d "2 years ago" +%s)
  END_TIME=$(date -d "1 year ago" +%s)
  start_time=$((END_TIME-60))
  STEP=$((3600*24*365))
  UPTIME_PERCENTAGE=$(curl -s -G --data-urlencode "query=sum(sum_over_time(kube_deployment_status_replicas_updated{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) / sum(sum_over_time(kube_deployment_status_replicas{namespace=\"$NAMESPACE\", deployment=\"$DEPLOYMENT\"}[60s])) or on() vector(0)" --data-urlencode "start=$((END_TIME-60)).2288918" --data-urlencode "end=$END_TIME.2288918" --data-urlencode "step=$STEP" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  DOWNTIME_SECONDS=$(calculate_downtime_seconds_from_percentage "${UPTIME_PERCENTAGE}" "$((END_TIME-STEP))" "${END_TIME}")
  METRIC="uptime_exporter_in_two_years_ago{prometheus_job=\"${DEPLOYMENT}\", downtime_seconds=\"${DOWNTIME_SECONDS}\", namespace=\"$NAMESPACE\"} ${UPTIME_PERCENTAGE}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

done

echo -e "$METRICS" > /tmp/metrics.log