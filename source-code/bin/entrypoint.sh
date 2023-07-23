#!/bin/bash

echo ""
echo " __   __  _______  _______  ___   __   __  _______    _______  __   __  _______  _______  ______    _______  _______  ______   "
echo "|  | |  ||       ||       ||   | |  |_|  ||       |  |       ||  |_|  ||       ||       ||    _ |  |       ||       ||    _ |  "
echo "|  | |  ||    _  ||_     _||   | |       ||    ___|  |    ___||       ||    _  ||   _   ||   | ||  |_     _||    ___||   | ||  "
echo "|  |_|  ||   |_| |  |   |  |   | |       ||   |___   |   |___ |       ||   |_| ||  | |  ||   |_||_   |   |  |   |___ |   |_||_ "
echo "|       ||    ___|  |   |  |   | |       ||    ___|  |    ___| |     | |    ___||  |_|  ||    __  |  |   |  |    ___||    __  |"
echo "|       ||   |      |   |  |   | | ||_|| ||   |___   |   |___ |   _   ||   |    |       ||   |  | |  |   |  |   |___ |   |  | |"
echo "|_______||___|      |___|  |___| |_|   |_||_______|  |_______||__| |__||___|    |_______||___|  |_|  |___|  |_______||___|  |_|"
echo ""

# in case config is via variable
if [ "${CONFIG_FILE}" != "" ]; then
    echo "${CONFIG_FILE}" > /home/config.yaml
    export CONFIG_FILE=""
fi

export PROMETHEUS_URL=$(yq e '.config.prometheus_url' /home/config.yaml)
export NAMESPACE=$(yq e '.config.namespace' /home/config.yaml)

/usr/local/bin/uptime-exporter &

service cron start & tail -f /var/log/cron.log