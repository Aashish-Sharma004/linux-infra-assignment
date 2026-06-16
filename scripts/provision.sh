#!/bin/bash
set -euo pipefail

echo "========================================"
echo " Starting Server Provisioning..."
echo "========================================"

if [ "$EUID" -ne 0 ]; then
echo "Error: Please run this script with sudo."
exit 1
fi


if grep -q 'Ubuntu'  /etc/os-release; then
   echo " OS Check passed:  Ubuntu detected."
else
  echo  "Error: This provisioning script requires Ubuntu."
  exit 1
fi



echo "Configuring hostname and timezone..."
hostnamectl set-hostname infra-demo-node
timedatectl set-timezone UTC


echo "Updating packages and installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl ufw tree python3 python3-pip
apt-get install -y curl ufw tree python3 python3-pip openssh-server

USER_NAME="sysops"
if id "$USER_NAME" &>/dev/null; then
   echo " User 'USER_NAME' already exists. Skipping creation."
else
  echo "Creating operational user: $USER_NAME..."
  useradd -m -s /bin/bash "$USER_NAME"
  echo "$USER_NAME ALL=(ALL) NOPASSWD :ALL" > /etch/sudoers.d/$USER_NAME
  chmod 0440 /etc/sudoers.d/$USER_NAME
  echo " User '$USER_NAME' created successfully."
fi


echo "Deploying infra-demo service..."
mkdir -p /var/www/infra-demo
echo "OK - Health Check Passed" > /var/www/infra-demo/index.html
chown -R sysops:sysops /var/www/infra-demo
cp config/infra-demo.env /etc/default/infra-demo.env
chmod 644 /etc/default/infra-demo.env

cp systemd/infra-demo.service /etc/systemd/system/infra-demo.service
chmod 644 /etc/systemd/system/infra-demo.service

echo "Deploying infra-maintenance timer..."
cp systemd/infra-maintenance.service /etc/systemd/system/
cp systemd/infra-maintenance.timer /etc/systemd/system/


mkdir -p /opt/infra-demo/scripts
cp scripts/maintenance.sh /opt/infra-demo/scripts/
chmod +x /opt/infra-demo/scripts/maintenance.sh

systemctl daemon-reload
systemctl enable infra-demo.service
echo "Deploying infra-maintenance timer..."
cp systemd/infra-maintenance.service /etc/systemd/system/
cp systemd/infra-maintenance.timer /etc/systemd/system/

systemctl enable infra-maintenance.timer
systemctl start infra-maintenance.timer

systemctl restart infra-demo.service


echo "Applying firewall rules..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 8080/tcp
ufw --force enable

# 7. Security Hardening (SSH)
echo "Hardening SSH configuration..."

# Create a backup of the original config file just in case
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Disable Root Login using sed (stream editor)
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart the SSH service to apply the new rules immediately
systemctl restart sshd

echo "========================================"
echo " Provisioning and Service Deployment Complete!"
echo "========================================"

