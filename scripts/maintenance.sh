#!/bin/bash
set -euo pipefail


mkdir -p /var/log/infra-demo
LOG_FILE="/var/log/infra-demo/maintenance.log"

echo "========================================" >> "$LOG_FILE"
echo "Maintenance started at $(date)" >> "$LOG_FILE"


echo "Running apt-get autoremove and clean..." >> "$LOG_FILE"
apt-get autoremove -y >> "$LOG_FILE" 2>&1
apt-get clean >> "$LOG_FILE" 2>&1

echo "Maintenance completed at $(date)" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
