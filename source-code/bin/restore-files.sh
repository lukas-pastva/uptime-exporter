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
if [ -z "${DEST_DIR+xxx}" ]; then
  read -p "Destination directory (example: /var/www/html): " DEST_DIR
  export DEST_DIR=${DEST_DIR}
fi
if [ -z "${CLEANUP+xxx}" ]; then
  read -p "Cleanup destination directory? (values: yes/no): " CLEANUP
  export CLEANUP=${CLEANUP}
fi

POD="${POD_SHORT}"
if [[ "${POD}" != "" ]]; then
  mkdir -p {/tmp/restore,/tmp/restore-unzipped}

  download_file "${FILE_ZIP}" "/tmp/restore/restore.zip"

  unzip -qq "/tmp/restore/restore.zip" -d "/tmp/restore-unzipped" && rm -rf "/tmp/restore"

  if [[ "${CLEANUP}" == "yes" ]]; then
    echo_message "Cleaning up"
    docker exec -i "${POD}" bash -c "find ${DEST_DIR} -mindepth 1 -delete"
  fi

  echo_message "Copying files"
  docker cp "/tmp/restore-unzipped/." "${POD}:${DEST_DIR}/"

  rm -R "/tmp/restore-unzipped"
fi