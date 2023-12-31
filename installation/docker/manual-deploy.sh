#!/bin/bash

set -e
echo "Manually deploying Uptime-exporter into Docker."

. .env 2>/dev/null || true

export IMAGE="lukaspastva/uptime-exporter:latest"

docker stop uptime-exporter || true
docker container rm uptime-exporter || true
docker image rm ${IMAGE} || true
docker run -e "NAMESPACE=my-app" -e "CONFIG_FILE=|
config:
  prometheus_url: http://prometheus-operated.monitoring:9090
  metrics:
    - name: test-metric
      deployments:
        - cluster: test-cluster
          namespace: test-namespace
          name: test-deployment
  uptimes:
    - start: \"2023-11-16T8:00:00Z\"
      end: \"2023-11-28T8:00:00Z\"" --name uptime-exporter ${IMAGE} .