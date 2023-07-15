#!/bin/bash
source functions.inc.sh

export PODS=$(yq e '.uptime-exporter-config.metrics.pods_mysql.[].name' /home/uptime-exporter-config.yaml)
export METRICS=""
export IFS=$'\n'
for POD in $PODS;
do
  if [[ "${POD}" != "" ]]; then
    # try to get username from config
    export SQL_USER=$(yq e ".uptime-exporter-config.backups.dbs_mysql | with_entries(select(.value.name == \"$POD\")) | .[].username" /home/uptime-exporter-config.yaml)
    if [[ "${SQL_USER}" == "null" ]]; then
      export SQL_USER="root"
    fi

    # try to get password from config
    export SQL_PASS=$(yq e ".uptime-exporter-config.backups.dbs_mysql | with_entries(select(.value.name == \"$POD\")) | .[].password" /home/uptime-exporter-config.yaml)
    if [[ "${SQL_PASS}" == "null" ]]; then
      export SQL_PASS=$(docker exec -i ${POD} bash -c 'echo ${MYSQL_ROOT_PASSWORD}')
    fi

    while read QUERY_NAME;
    do
      QUERY=$(yq e ".uptime-exporter-config.metrics.pods_mysql | with_entries(select(.value.name == \"$POD\")) | .[].queries | with_entries(select(.value.name == \"$QUERY_NAME\" )) | .[].query" /home/uptime-exporter-config.yaml)
      if [[ "${QUERY^^}" != *"DROP"* ]]; then
        if [[ "${QUERY^^}" != *"UPDATE"* ]]; then
          if [[ "${QUERY^^}" != *"TRUNCATE"* ]]; then
            if [[ "${QUERY^^}" != *"DELETE"* ]]; then
              if [[ "${QUERY^^}" != *"ALTER"* ]]; then
                if [[ "${QUERY^^}" != *"INSERT"* ]]; then
                  echo ""
                  echo ""
                  echo ""
                  export QUERY_RESULT=$(echo "${QUERY}" | docker exec -i "${POD}" mysql -u${SQL_USER} -p${SQL_PASS} 2>/dev/null)
                  export IFS=$'\n'
                  for QUERY_LINE in ${QUERY_RESULT}; do
                    export RESULT_NAME=$(echo "${QUERY_LINE}" | awk -F'\t' '{print $1}')
                    export RESULT_VALUE=$(echo "${QUERY_LINE}" | awk -F'\t' '{print $2}')

                    if [ "$RESULT_VALUE" != "value" ]; then
                      if [ "$RESULT_VALUE" != "NULL" ]; then
                        METRIC="uptime-exporter_sql_query{pod=\"${POD}\",query_name=\"${QUERY_NAME}\",label_name=\"${RESULT_NAME}\"} ${RESULT_VALUE}"
                        METRICS=$(echo -e "$METRICS\n$METRIC")
                      fi
                    fi
                  done
                fi
              fi
            fi
          fi
        fi
      fi
    done < <(yq e ".uptime-exporter-config.metrics.pods_mysql | with_entries(select(.value.name == \"$POD\")) | .[].queries.[].name" /home/uptime-exporter-config.yaml)
  fi
done

GW_URL=$(yq e ".uptime-exporter-config.prometheus_pushgateway" /home/uptime-exporter-config.yaml)
if [ -z "$GW_URL" ]; then
  echo -e "$METRICS"
else
  echo -e "$METRICS" | curl --data-binary @- "${GW_URL}"
fi

