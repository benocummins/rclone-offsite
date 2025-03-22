# Rclone Offsite Azure VM 🧠💾☁️

This Terraform setup spins up a lightweight Ubuntu VM in Azure with a GUI + RDP access to test and validate encrypted `rclone` backups.

## 🔥 What It Does

- Deploys Ubuntu 22.04 with XFCE desktop
- Sets up Remote Desktop (RDP) access
- Locks ports to your public IP for security
- Runs `cloud-init` to install:
  - `rclone`
  - `xfce4`
  - `xrdp`
  - `vlc`, `ristretto`, `firefox` for media validation
- Easily destroy and rebuild to **avoid ongoing Azure charges**

---

## 🚀 How to Use It

### 1. Clone the Repo
```bash
git clone https://github.com/benocummins/rclone-offsite.git
cd rclone-offsite

Make sure to update my_ip in the variables.tf each time it is recreated to have the most up-to-date public IP address