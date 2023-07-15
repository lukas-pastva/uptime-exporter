#!/bin/bash

set -e
echo "Manually deploying Conveior into Docker."

. .env 2>/dev/null || true


export IMAGE="lukaspastva/uptime-exporter:latest"

docker stop uptime-exporter || true
docker container rm uptime-exporter || true
docker image rm ${IMAGE} || true
docker run --name uptime-exporter ${IMAGE} .