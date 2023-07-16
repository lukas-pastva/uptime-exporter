#!/bin/bash
export $(xargs -0 -a "/proc/1/environ") 2>/dev/null

source functions.inc.sh

export EPOCH=$(date +%s)
METRIC="uptime_exporter_heart_beat ${EPOCH}"
METRICS=$(echo -e "$METRICS\n$METRIC")

# iterate over Prometheus jobs
JOBS=$(curl -s "$PROMETHEUS_URL/api/v1/label/job/values" | jq -r '.data[]')
for JOB in $JOBS; do

  #curl -G "$PROMETHEUS_URL/api/v1/query_range" --data-urlencode "query=sum(sum_over_time(up{job=\"sys-uptime-exporter\"}[3600s])) / sum(count_over_time(up{job=\"sys-uptime-exporter\"}[3600s]))" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=60" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100'
  #curl -G "$PROMETHEUS_URL/api/v1/query_range" --data-urlencode "query=sum(sum_over_time(up{job=\"sys-uptime-exporter\"}[3600s])) / sum(count_over_time(up{job=\"sys-uptime-exporter\"}[3600s]))" --data-urlencode "start=1689437496.2288918" --data-urlencode "end=1689447315.9632373" --data-urlencode "step=60" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100'

  # PER last XXX
  # uptime per last 24 hours
  for i in {0..24}; do
    # start_time=$(date -d"$i day ago 00:00:00" +%s)
    end_time=$(date -d "-$i hours" +%s)
    start_time=$((end_time-60))
    step="3600"
    # UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
    UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    METRIC="uptime_exporter_per_last_24_hours{hour_in_past=\"hour-$i\",prometheus_job=\"${JOB}\"} ${UPTIME}"
    METRICS=$(echo -e "$METRICS\n$METRIC")
  done

  # PER last XXX
  # uptime per last 10 days
  for i in {0..9}; do
    # start_time=$(date -d"$i day ago 00:00:00" +%s)
    end_time=$(date -d"$i day ago $(date +%T)" +%s)
    start_time=$((end_time-60))
    step=$((3600*24))
    # UPTIME=$(curl -s -G --data-urlencode "query=(avg(avg_over_time(up{job=\"${JOB}\"}[$step]) or on() vector(0) )*100)" --data-urlencode "start=$start_time" --data-urlencode "end=$end_time" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query" | jq -r '.data.result[]?.value[1]')
    UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    METRIC="uptime_exporter_per_last_10_days{day_in_past=\"day-$((10-$i))\",prometheus_job=\"${JOB}\"} ${UPTIME}"
    METRICS=$(echo -e "$METRICS\n$METRIC")
  done

  # uptime per last 10 weeks
  for i in {0..9}; do
    # start_time=$(date -d"$i week ago 00:00:00" +%s)
    end_time=$(date -d"$i week ago $(date +%T)" +%s)
    start_time=$((end_time-60))
    step=$((3600*24*7))
    UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    METRIC="uptime_exporter_per_last_10_weeks{week_in_past=\"week-$((10-$i))\",prometheus_job=\"${JOB}\"} ${UPTIME}"
    METRICS=$(echo -e "$METRICS\n$METRIC")
  done

  # uptime per last 12 months
  for i in {0..11}; do
    # start_time=$(date -d"$i month ago 00:00:00" +%s)
    end_time=$(date -d"$i month ago $(date +%T)" +%s)
    start_time=$((end_time-60))
    step=$((3600*24*30))
    UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
    METRIC="uptime_exporter_per_last_12_months{month_in_past=\"month-$((12-$i))\",prometheus_job=\"${JOB}\"} ${UPTIME}"
    METRICS=$(echo -e "$METRICS\n$METRIC")
  done


  # IN last XXX
  # uptime in last 7 days
  # start_time=$(date -d "7 day ago" -u +%s)
  end_time=$(date -u +%s)
  start_time=$((end_time-60))
  step=$((3600*24*30))
  UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  METRIC="uptime_exporter_in_last_7_days{prometheus_job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in last 30 days
  # start_time=$(date -d "30 day ago" -u +%s)
  end_time=$(date -u +%s)
  start_time=$((end_time-60))
  step=$((3600*24*30))
  UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  METRIC="uptime_exporter_in_last_30_days{prometheus_job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in previous month
  # start_time=$(date -d "$(date +%Y-%m-01) -1 month" +%s)
  end_time=$(date -d "$(date +%Y-%m-01) -1 second" +%s)
  start_time=$((end_time-60))
  step=$((3600*24*30))
  UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  METRIC="uptime_exporter_in_previous_month{prometheus_job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in three months ago
  # start_time=$(date -d "3 months ago" +%s)
  end_time=$(date -u +%s)
  start_time=$((end_time-60))
  step=$((3600*24*90))
  UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  METRIC="uptime_exporter_in_three_months_ago{prometheus_job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in this year
  # start_time=$(date -d "$(date +%Y)-01-01 00:00:00" +%s)
  end_time=$(date -u +%s)
  start_time=$((end_time-60))
  step=$((3600*24*$(date +%j)))
  UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  METRIC="uptime_exporter_in_this_year{prometheus_job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in one year ago
  # start_time=$(date -d "1 year ago" +%s)
  end_time=$(date -u +%s)
  start_time=$((end_time-60))
  step=$((3600*24*365))
  UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  METRIC="uptime_exporter_in_one_year_ago{prometheus_job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

  # uptime in two years ago
  # start_time=$(date -d "2 years ago" +%s)
  end_time=$(date -d "1 year ago" +%s)
  start_time=$((end_time-60))
  step=$((3600*24*365))
  UPTIME=$(curl -s -G --data-urlencode "query=sum(sum_over_time(up{job=\"$JOB\"}[3600s])) / sum(count_over_time(up{job=\"$JOB\"}[3600s])) or on() vector(0)" --data-urlencode "start=$start_time.2288918" --data-urlencode "end=$end_time.2288918" --data-urlencode "step=$step" "$PROMETHEUS_URL/api/v1/query_range" | jq -r '.data.result[].values[]' | jq -s 'map(.[1] | tonumber) | (add / length) * 100')
  METRIC="uptime_exporter_in_two_years_ago{prometheus_job=\"${JOB}\"} ${UPTIME}"
  METRICS=$(echo -e "$METRICS\n$METRIC")

done

echo -e "$METRICS" > /tmp/metrics.log