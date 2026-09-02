<div align="center">

# ⚡ mgr

**Lightweight, Docker Compose-like CLI and Auto-Healing Watchdog for Systemd Services.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash%204.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Platform-Linux%20%28systemd%29-blue.svg)](https://systemd.io/)

*Run bare-metal microservices on low-resource VPS (1-2GB RAM) and Raspberry Pi with the convenience of Docker Compose and zero container overhead.*

</div>

---

## 🎯 Why `mgr`?

When hosting microservices and APIs on budget VPS (Hetzner, DigitalOcean, Linode, AWS Lightsail) or Raspberry Pi:
* **Docker Overhead:** Running `dockerd`, `containerd-shim`, virtual bridges, and iptables rules often wastes **150MB - 300MB+ RAM** before your application even starts.
* **Bare-Metal Simplicity:** Systemd is fast, robust, and uses **0 extra RAM**. However, typing `systemctl restart service1 service2`, checking multiple logs, and remembering service names is inconvenient compared to `docker compose`.
* **`mgr` bridges the gap:** It gives you a clean `docker compose`-like CLI, colorized process tables, alias resolution, and an auto-healing background watchdog for your native Linux services.

---

## ⚡ Quick Install

Install in one command:

```bash
curl -sSL https://raw.githubusercontent.com/poqob/mgr/main/install.sh | sudo bash
```

Or manually:

```bash
git clone https://github.com/poqob/mgr.git
cd mgr
sudo cp mgr /usr/local/bin/mgr
sudo chmod +x /usr/local/bin/mgr
```

---

## 🚀 Quick Start

### 1. Initialize Configuration
Generate a starter `mgr.conf` in your current directory or `/etc/mgr/`:

```bash
mgr init
```

### 2. Define Your Services (`mgr.conf`)
Configure your services using a simple single-line syntax:

```ini
[services]
# name     = systemd_unit_name    : port     : description            : aliases (optional)
proxy      = caddy.service        : 80,443   : Caddy Reverse Proxy    : web,caddy
api        = my-backend.service   : 8000     : FastAPI REST Backend   : backend,server
db         = mongod.service       : 27017    : MongoDB Database       : mongo
cache      = redis-server.service : 6379     : Redis In-Memory Cache  : redis
```

### 3. Manage Everything with Simple Commands

```bash
# Check status, memory, PID, ports & auto-heal dead services
mgr

# Restart specific services (or all if omitted)
mgr restart api db
mgr up

# Stop services
mgr stop api
mgr down

# Tail live journal logs
mgr logs api

# Force kill (SIGKILL)
mgr kill api
```

---

## 📊 Live Status Output

```
========================================================================
           mgr - Services Status & Health Overview                      
  Config: /etc/mgr/mgr.conf
========================================================================
SERVICE        STATUS       PID      MEMORY     PORT       DESCRIPTION           
------------------------------------------------------------------------
proxy          RUNNING      4000284  58MB       80,443     Caddy Reverse Proxy   
api            RUNNING      25828    48MB       8008       Sahibe PDKS Backend   
db             RUNNING      24652    115MB      27017      MongoDB Database      
cache          RUNNING      23715    4MB        6379       Redis In-Memory Store 
========================================================================
System Memory: Used: 525Mi / Total: 1.9Gi (Available: 1.4Gi)
```

---

## 🛡️ Auto-Healing Watchdog

`mgr` provides automatic recovery for crashed services:

1. **Systemd Level:** If configured with `Restart=always`, systemd automatically revives crashed processes within seconds.
2. **Cron Watchdog (`mgr -w`):** Runs every 1 minute via `/etc/cron.d/mgr-watchdog`. If any service is detected as dead or failed, it automatically restarts it and logs the recovery event to `/var/log/mgr-watchdog.log`.

Install or uninstall the cron watchdog anytime:

```bash
sudo mgr install-watchdog
sudo mgr uninstall-watchdog
```

---

## 📖 CLI Reference

| Command | Aliases | Description |
| :--- | :--- | :--- |
| `mgr` | `mgr -c`, `mgr status`, `mgr check` | Displays live status table and auto-heals any dead services |
| `mgr up [srv...]` | `mgr start`, `mgr restart`, `mgr -r` | Starts or restarts specified services (or ALL) |
| `mgr down [srv...]`| `mgr stop`, `mgr shutdown`, `mgr -s`| Stops specified services (or ALL) |
| `mgr kill [srv...]`| `mgr -k` | Sends `SIGKILL` to force terminate processes |
| `mgr logs <srv>` | `mgr -l <srv>`, `mgr log` | Streams live `journalctl` log output |
| `mgr watchdog` | `mgr -w` | Silent check & auto-heal mode for cron |
| `mgr init` | | Creates a template `mgr.conf` in the current directory |
| `mgr install-watchdog` | | Installs 1-minute auto-healing cron job |
| `mgr uninstall-watchdog`| | Removes auto-healing cron job |
| `mgr version` | `mgr -v` | Shows version information |
| `mgr help` | `mgr -h` | Shows usage and options |

---

## ⚙️ Configuration File Priority

`mgr` automatically searches for `mgr.conf` in the following order:

1. `$MGR_CONFIG` *(Environment variable)*
2. `./mgr.conf` *(Current working directory)*
3. `~/.config/mgr/mgr.conf` *(User directory)*
4. `/etc/mgr/mgr.conf` *(Global config directory)*
5. `/etc/mgr.conf` *(System config)*

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

Developed with ❤️ by [poqob](https://github.com/poqob) & [DagSolution](https://dagsolution.com).
