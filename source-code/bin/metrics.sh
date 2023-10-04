#!/bin/bash
export $(xargs -0 -a "/proc/1/environ") 2>/dev/null
source functions.inc.sh

RESULT="# scraping start $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

RESULTS="uptime_exporter_heart_beat ${EPOCH}"
RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

# iterate over metrics
METRICS_COUNT=$(yq e '.config.metrics | length' /home/config.yaml)
for ((m=0; m<$METRICS_COUNT; m++)); do
  METRIC=$(yq e ".config.metrics[$m].name" /home/config.yaml)
  MEASURE_START=$(yq e ".config.metrics[$m].measureStart" /home/config.yaml)
  MEASURE_START_UNIX=$(date -d "$MEASURE_START" +%s)
  QUERY_COUNT=$(yq e ".config.metrics[$m].queries | length" /home/config.yaml)


  # IN last XXX
  # uptime in last 7 days
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*7))
  for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
  done
  PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
  if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
      echo "Percentage was over: $PERCENTAGE in uptime_exporter_in_last_7_days $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
      PERCENTAGE=100
  fi
  RESULT="uptime_exporter_in_last_7_days{metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
  RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

  # uptime in last 30 days
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*30))
  for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
  done
  PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
  if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
      echo "Percentage was over: $PERCENTAGE in uptime_exporter_in_last_30_days $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
      PERCENTAGE=100
  fi
  RESULT="uptime_exporter_in_last_30_days{metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
  RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

  # uptime in previous month
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -d "$(date +%Y-%m-01) -1 second" +%s)
  STEP=$((3600*24*30))
  for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
  done
  PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
  if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
      echo "Percentage was over: $PERCENTAGE in uptime_exporter_in_previous_month $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
      PERCENTAGE=100
  fi
  RESULT="uptime_exporter_in_previous_month{metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
  RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

  # uptime in three months ago
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*90))
  for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
  done
  PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
  if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
      echo "Percentage was over: $PERCENTAGE in uptime_exporter_in_three_months_ago $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
      PERCENTAGE=100
  fi
  RESULT="uptime_exporter_in_three_months_ago{metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
  RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

  # uptime in this year
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*$(date +%j)))
  for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
  done
  PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
  if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
      echo "Percentage was over: $PERCENTAGE in uptime_exporter_in_this_calendar_year $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
      PERCENTAGE=100
  fi
  RESULT="uptime_exporter_in_this_calendar_year{metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
  RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

  # uptime in one year ago
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -u +%s)
  STEP=$((3600*24*365))
  for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
  done
  PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
  if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
      echo "Percentage was over: $PERCENTAGE in uptime_exporter_in_last_365_days $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
      PERCENTAGE=100
  fi
  RESULT="uptime_exporter_in_last_365_days{metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
  RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

  # uptime in two years ago
  UPTIME_PERCENTAGE_SUM=0
  END_TIME=$(date -d "1 year ago" +%s)
  STEP=$((3600*24*365))
  for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
  done
  PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
  if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
      echo "Percentage was over: $PERCENTAGE in uptime_exporter_in_two_years_ago $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
      PERCENTAGE=100
  fi
  RESULT="uptime_exporter_in_two_years_ago{metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
  RESULTS=$(metric_add "${RESULT}" "${RESULTS}")



  # PER last XXX
  # uptime per last 12 months
  for j in {0..11}; do
    UPTIME_PERCENTAGE_SUM=0
    END_TIME=$(date -d"$j month ago $(date +%T)" +%s)
    STEP=$((3600*24*30))
    for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
    done
    PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
    if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
        echo "Percentage was over: $PERCENTAGE in uptime_exporter_per_last_12_months $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
        PERCENTAGE=100
    fi
    RESULT="uptime_exporter_per_last_12_months{month_in_past=\"$(date -d "@$END_TIME" '+%Y-%m')\", metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
    RESULTS=$(metric_add "${RESULT}" "${RESULTS}")
  done

  # uptime per last 4 weeks
  for j in {0..3}; do
    UPTIME_PERCENTAGE_SUM=0
    END_TIME=$(date -d"$j week ago $(date +%T)" +%s)
    STEP=$((3600*24*7))
    for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
    done
    PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
    if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
        echo "Percentage was over: $PERCENTAGE in uptime_exporter_per_last_4_weeks $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
        PERCENTAGE=100
    fi
    RESULT="uptime_exporter_per_last_4_weeks{week_in_past=\"week nr. $(date -d "@$END_TIME" '+%V')\", metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
    RESULTS=$(metric_add "${RESULT}" "${RESULTS}")
  done

  # uptime per last 7 days
  for j in {0..6}; do
    UPTIME_PERCENTAGE_SUM=0
    END_TIME=$(date -d"$j day ago $(date +%T)" +%s)
    STEP=$((3600*24))
    for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
    done
    PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
    if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
        echo "Percentage was over: $PERCENTAGE in uptime_exporter_per_last_7_days $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
        PERCENTAGE=100
    fi
    RESULT="uptime_exporter_per_last_7_days{day_in_past=\"$(date -d "@$END_TIME" '+%Y-%m-%d')\", metric=\"${METRIC}\"} $(echo "scale=5; $PERCENTAGE" | bc)"
    RESULTS=$(metric_add "${RESULT}" "${RESULTS}")
  done

  # uptime per last 24 hours
  for j in {0..24}; do
    UPTIME_PERCENTAGE_SUM=0
    END_TIME=$(date -d "-$j hours" +%s)
    STEP=3600
    for ((i=0; i<$QUERY_COUNT; i++)); do
    UPTIME_PERCENTAGE_CURRENT=$(calculate_uptime_percentage "$m" "$i" "$END_TIME" "$STEP" "$MEASURE_START_UNIX")
    UPTIME_PERCENTAGE_SUM=$(echo "scale=5;$UPTIME_PERCENTAGE_SUM + $UPTIME_PERCENTAGE_CURRENT" | bc)
    done
    PERCENTAGE=$(echo "scale=5; $UPTIME_PERCENTAGE_SUM/$i" | bc)
    if (( $(echo "$PERCENTAGE > 100" | bc -l) )); then
        echo "Percentage was over: $PERCENTAGE in uptime_exporter_per_last_24_hours $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> error.log
        PERCENTAGE=100
    fi
    RESULT="uptime_exporter_per_last_24_hours{hour_in_past=\"$(date -d "@$END_TIME" '+%Y-%m-%d %H')\", metric=\"${METRIC}\"} $PERCENTAGE"
    RESULTS=$(metric_add "${RESULT}" "${RESULTS}")
  done

done

RESULT="uptime_exporter_scrape_time $(($(date +%s)-EPOCH))"
RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

RESULT="# scraping end $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
RESULTS=$(metric_add "${RESULT}" "${RESULTS}")

echo -e "$RESULTS" > /tmp/metrics.log