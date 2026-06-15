# Linux Infrastructure Intern Assignment

## Project Overview
This repository contains automated provisioning and validation scripts to configure an Ubuntu-based Linux server. The automation is designed to be idempotent and handles system updates, security hardening, user management, and the deployment of a Python-based HTTP health service managed by systemd.

## Milestones Completed
1. **Base Server Setup:** Automated package installation (`curl`, `ufw`, `tree`, `python3`) and operational user creation (`sysops`).
2. **Service Deployment:** Configuration of a dedicated systemd service (`infra-demo.service`) serving an HTTP endpoint on port 8080 from a secure, restricted directory.
3. **Security Hardening:** UFW firewall configuration to allow only required traffic (SSH and TCP/8080) and strict directory ownership.
4. **Automated Validation:** A comprehensive test script to verify service health, permissions, firewall status, and user persistence, which successfully passes after a full system reboot.

## Repository Structure
- `scripts/provision.sh`: Idempotent bash script for server configuration and service deployment.
- `scripts/validate.sh`: Automated health-check script to verify system state.
- `systemd/`: Contains the systemd unit file (`infra-demo.service`).
- `config/`: Contains the environment configuration (`infra-demo.env`).
- `evidence/`: Contains screenshots verifying milestone completion and reboot survival.

## How to Run

**1. Provision the Server**
Run the provisioning script with root privileges. It is safe to run multiple times.
\`\`\`bash
sudo ./scripts/provision.sh
\`\`\`

**2. Validate the Setup**
Run the validation script to verify all services and security rules are active.
\`\`\`bash
./scripts/validate.sh
\`\`\`
