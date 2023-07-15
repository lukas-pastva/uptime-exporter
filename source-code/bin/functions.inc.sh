#!/bin/bash
#set -e

function echo_message {
  echo -e "\n# $1"
}

function download_file {
  echo_message "Downloading ${1} into ${2}"

  if [ "${BUCKET_TYPE}" == "S3" ]; then
      download_file_s3 "$1" "$2"
  fi
  if [ "${BUCKET_TYPE}" == "GCP" ]; then
      download_file_gcp "$1" "$2"
  fi
}

export EPOCH=$(date +%s)
export DATE=$(date +"%Y-%m-%dT%H-%M-%SZ")
export ANTI_DATE=$(( 10000000000 - $(date +%s) ))
export BUCKET_TYPE=$(yq e '.uptime-exporter-config.bucket_type' /home/uptime-exporter-config.yaml)
export BUCKET_NAME=$(yq e '.uptime-exporter-config.bucket_name' /home/uptime-exporter-config.yaml)
export CONTAINER_ORCHESTRATOR=$(yq e '.uptime-exporter-config.container_orchestrator' /home/uptime-exporter-config.yaml)
