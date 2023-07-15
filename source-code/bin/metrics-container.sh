#!/bin/bash
source functions.inc.sh

CONTAINER_LIST=$(docker ps -f status=running --format "{{.Names}}")
export METRICS=""
export IFS=","
while read POD;
do
  export TYPE=$(yq e ".uptime-exporter-config.metrics.containers | with_entries(select(.value.name == \"$POD\")) | .[].type" /home/uptime-exporter-config.yaml)

  export RUNNING=$(echo ${CONTAINER_LIST} | grep ${POD})
  if [[ "${RUNNING}" == *"${POD}"* ]]; then
    VALUE=1
  else
    if [ "$TYPE" == "info" ]; then
      VALUE=2
    else
      VALUE=3
    fi
  fi
  METRIC="uptime-exporter_dockerContainer{label_name=\"${POD}\"} ${VALUE}"
  METRICS=$(echo -e "$METRICS\n$METRIC")
done < <(yq e ".uptime-exporter-config.metrics.containers | .[].name" /home/uptime-exporter-config.yaml)

GW_URL=$(yq e ".uptime-exporter-config.prometheus_pushgateway" /home/uptime-exporter-config.yaml)
if [ -z "$GW_URL" ]; then
  echo -e "$METRICS"
else
  echo -e "$METRICS" | curl --data-binary @- "${GW_URL}"
fi