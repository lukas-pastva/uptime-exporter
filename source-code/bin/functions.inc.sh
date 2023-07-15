#!/bin/bash
#set -e

function echo_message {
  echo -e "\n# $1"
}

export EPOCH=$(date +%s)
export DATE=$(date +"%Y-%m-%dT%H-%M-%SZ")
export ANTI_DATE=$(( 10000000000 - $(date +%s) ))