#!/bin/bash
set -euo pipefail

echo "========================================"
echo " Running System Validation Checks..."
echo "========================================"

# 1. User Check
if id "sysops" &>/dev/null; then
    echo "✓ User 'sysops' exists."
else
    echo "✗ User 'sysops' NOT FOUND."
fi

# 2. Firewall Check
if sudo ufw status | grep -q "Status: active"; then
    echo "✓ Firewall is active."
else
    echo "✗ Firewall is INACTIVE."
fi

# 3. Service Check
if systemctl is-active --quiet infra-demo.service; then
    echo "✓ infra-demo service is running."
else
    echo "✗ infra-demo service is NOT running."
fi

if systemctl is-enabled --quiet infra-demo.service; then
    echo "✓ infra-demo service is enabled on boot."
else
    echo "✗ infra-demo service is NOT enabled."
fi

# 4. HTTP Health Check
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" http://localhost:8080 || echo "FAILED")
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✓ HTTP health check passed (Status: 200)."
else
    echo "✗ HTTP health check failed (Status: $HTTP_STATUS)."
fi

# 5. File Permissions Check
if [ $(stat -c "%U" /var/www/infra-demo) = "sysops" ]; then
    echo "✓ Web directory is securely owned by sysops."
else
    echo "✗ Web directory ownership is incorrect."
fi

echo "========================================"
echo " Validation Complete!"
echo "========================================"
