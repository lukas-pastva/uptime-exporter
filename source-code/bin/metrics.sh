#!/bin/bash
export $(xargs -0 -a "/proc/1/environ") 2>/dev/null

source functions.inc.sh

export EPOCH=$(date +%s)
METRIC="uptime_exporter_heart_beat ${EPOCH}"
METRICS=$(echo -e "$METRICS\n$METRIC")

JOBS=$(curl -s "$PROMETHEUS_URL/api/v1/label/job/values" | jq -r '.data[]')
for JOB in $JOBS; do

  # uptime last day
  query="up{job=\"$JOB\"}"
  start_time=$(date -d "1 day ago" -u +%s)
  end_time=$(date -u +%s)
  step="1d"
  UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
  METRIC="uptime_exporter_last_day{job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime last week
  query="up{job=\"$JOB\"}"
  start_time=$(date -d "last week monday" +%s)
  end_time=$(date -d "last week sunday 23:59:59" +%s)
  step="7d"
  UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
  METRIC="uptime_exporter_last_week{job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime last 7 days
  query="up{job=\"$JOB\"}"
  start_time=$(date -d "7 day ago" -u +%s)
  end_time=$(date -u +%s)
  step="7d"
  UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
  METRIC="uptime_exporter_last_7_days{job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime last 30 days
  query="up{job=\"$JOB\"}"
  start_time=$(date -d "30 day ago" -u +%s)
  end_time=$(date -u +%s)
  step="30d"
  UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
  METRIC="uptime_exporter_last_30_days{job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime previous month
  query="up{job=\"$JOB\"}"
  start_time=$(date -d "$(date +%Y-%m-01) -1 month" +%s)
  end_time=$(date -d "$(date +%Y-%m-01) -1 second" +%s)
  step="30d"
  UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
  METRIC="uptime_exporter_previous_month{job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime three months ago
  query="up{job=\"$JOB\"}"
  start_time=$(date -d "3 months ago" +%s)
  end_time=$(date -u +%s)
  step="90d"
  UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
  METRIC="uptime_exporter_three_months_ago{job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime this year
  query="up{job=\"$JOB\"}"
  start_time=$(date -d "$(date +%Y)-01-01 00:00:00" +%s)
  end_time=$(date -u +%s)
  step="$(date +%j)d"
  UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
  METRIC="uptime_exporter_this_year{job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime one year ago
  query="up{job=\"$JOB\"}"
  start_time=$(date -d "1 year ago" +%s)
  end_time=$(date -u +%s)
  step="365d"
  UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
  METRIC="uptime_exporter_one_year_ago{job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

done

rm /tmp/metrics.log || true
echo -e $METRICS > /tmp/metrics.log