#!/bin/bash
source functions.inc.sh

if [ -z "${POD_SHORT+xxx}" ]; then
  read -p "Pod: " POD_SHORT
  export POD_SHORT=${POD_SHORT}
fi
if [ -z "${FILE_ZIP+xxx}" ]; then
  read -p "Location of the zip file to be downloaded (example: dir/file.zip): " FILE_ZIP
  export FILE_ZIP=${FILE_ZIP}
fi
if [ -z "${DROP_DBS+xxx}" ]; then
  read -p "Drop all existing DBs ? (except system ones) (values: yes/no): " DROP_DBS
  export DROP_DBS=${DROP_DBS}
fi

POD="${POD_SHORT}"
if [[ "${POD}" != "" ]]; then

  mkdir -p /tmp/restore
  download_file "${FILE_ZIP}" "/tmp/restore/backup.zip"
  cd /tmp/restore && unzip -qq backup.zip && rm backup.zip

  # try to get username from config
  export SQL_USER=$(yq e ".uptime-exporter-config.backups.dbs_mysql | with_entries(select(.value.name == \"$POD_SHORT\")) | .[].username" /home/uptime-exporter-config.yaml)
  if [[ "${SQL_USER}" == "null" ]]; then
    export SQL_USER="root"
  fi

  # try to get password from config
  export SQL_PASS=$(yq e ".uptime-exporter-config.backups.dbs_mysql | with_entries(select(.value.name == \"$POD_SHORT\")) | .[].password" /home/uptime-exporter-config.yaml)
  if [[ "${SQL_PASS}" == "null" ]]; then
    export SQL_PASS=$(docker exec -i ${POD} bash -c 'echo ${MYSQL_ROOT_PASSWORD}')
  fi

  # dropping DBs if requested to do so
  if [[ "${DROP_DBS}" == "yes" ]]; then
    export DATABASE_LIST=$(echo 'show databases;' | docker exec -i "${POD}" bash -c "mysql -u ${SQL_USER} -p'${SQL_PASS}' 2>/dev/null" | grep -Fv -e 'Database' -e 'information_schema' -e 'mysql' -e 'performance_schema' -e 'sys' )
    export IFS=$'\n'
    for DATABASE_ITEM in $DATABASE_LIST;
    do
      echo_message "Dropping database ${DATABASE_ITEM}"
      docker exec -i "${POD}" mysql -u ${SQL_USER} -p${SQL_PASS} -e "drop database \`${DATABASE_ITEM}\`;" 2>/dev/null
    done
  fi

  for BACKUP_FILE in /tmp/restore/*
  do
    echo_message "Importing $BACKUP_FILE SQL file"
    docker exec -i "${POD}" mysql -u ${SQL_USER} -p${SQL_PASS} < "${BACKUP_FILE}" 2>/dev/null
  done
  rm -R "/tmp/restore"
  echo_message "DONE"
fi