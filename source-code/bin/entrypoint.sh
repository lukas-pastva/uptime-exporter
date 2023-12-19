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
    echo "${CONFIG_FILE}" > /tmp/config.yaml
    export CONFIG_FILE=""
fi

# Start uptime-exporter in the background
/usr/local/bin/uptime-exporter &

# Start cron in the foreground without using the service command
# It's important to start cron in a way that is compatible with a read-only root filesystem
cron -f -L 15 &

# Tail the cron log (if necessary)
# Make sure /var/log is writable (mounted as a volume or emptyDir in your Kubernetes configuration)
tail -f /var/log/cron.log
