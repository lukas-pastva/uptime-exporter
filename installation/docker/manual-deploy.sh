#!/bin/bash

set -e
echo "Manually deploying Uptime-exporter into Docker."

. .env 2>/dev/null || true

export IMAGE="lukaspastva/uptime-exporter:latest"

docker stop uptime-exporter || true
docker container rm uptime-exporter || true
docker image rm ${IMAGE} || true
docker run -e "NAMESPACE=my-app" -e "PROMETHEUS_URL=prometheus-operated.monitoring:9090" --name uptime-exporter ${IMAGE} .