#!/bin/bash
set -euo pipefail

echo "========================================"
echo " Starting Server Provisioning..."
echo "========================================"

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo."
  exit 1
fi

if grep -q 'Ubuntu' /etc/os-release; then
    echo " OS Check Passed: Ubuntu detected."
else
    echo "Error: This provisioning script requires Ubuntu."
    exit 1
fi


echo "configurating hostname and timezone..."
hostnamectl set-hostname infra-demo-node
timedatectl set-timezone UTC


echo "updating packages and installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update  -y
apt-get install  -y  curl ufw tree python3 python3-pip

USER_NAME="sysops"
if id "$USER_NAME" &>/dev/null; then
   echo "  User '$USER_NAME' already exists. Skipping creation."
else 
   echo "Creating operational user: $USER_NAME..."
   useradd -m -s /bin/bash "$USER_NAME"
  echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL " > /etc/sudoers.d/$USER_NAME
  chmod 0440 /etc/sudoers.d/$USER_NAME
  echo "  User ' $USER_NAME' created successfully ."
fi

echo "========================================"
echo " Base Provisioning Complete!"
echo "========================================"
