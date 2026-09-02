<div align="center">

# ⚡ mgr

**Lightweight, Docker Compose-like CLI, MCP Server & Auto-Healing Watchdog for Systemd Services.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash%204.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Platform-Linux%20%28systemd%29-blue.svg)](https://systemd.io/)
[![MCP](https://img.shields.io/badge/MCP-Protocol%20Ready-purple.svg)](https://modelcontextprotocol.io/)

*Run bare-metal microservices on low-resource VPS (1-2GB RAM) and Raspberry Pi with the convenience of Docker Compose, native AI Agent (MCP) support, and zero container overhead.*

</div>

---

## 🎯 Why `mgr`?

When hosting microservices and APIs on budget VPS (Hetzner, DigitalOcean, Linode, AWS Lightsail) or Raspberry Pi:
* **Docker Overhead:** Running `dockerd`, `containerd-shim`, virtual bridges, and iptables rules often wastes **150MB - 300MB+ RAM** before your application even starts.
* **Bare-Metal Simplicity:** Systemd is fast, robust, and uses **0 extra RAM**. However, typing `systemctl restart service1 service2`, checking multiple logs, and remembering service names is inconvenient compared to `docker compose`.
* **AI-Agent Ready (MCP):** Modern AI coding agents (Claude, Cursor, Windsurf, Antigravity) can connect directly to `mgr` via the Model Context Protocol to inspect server health, read logs, and restart crashed services automatically.

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

`mgr` is **ultra-forgiving** with spacing and formatting. Pick whichever syntax feels natural:

#### Option A: One-liner with details (colons or commas)
```ini
[services]
proxy   = caddy.service        : 80,443 : Caddy Web Proxy   : web,caddy
api     = my-backend.service   : 8000   : FastAPI REST API  : backend,server
db      = mongod.service       : 27017  : MongoDB Database  : mongo
cache   = redis-server.service : 6379   : Redis Store       : redis
```

#### Option B: Super Simple Key = Value (auto-detects `.service`)
```ini
api     = my-backend
db      = mongod
cache   = redis-server
proxy   = caddy
```

#### Option C: Minimal (one service per line)
```text
my-backend.service
mongod
redis-server
caddy
```

#### Option D: INI Section Blocks
```ini
[api]
unit = my-backend.service
port = 8000
desc = Main REST API
alias = backend,server

[db]
unit = mongod.service
port = 27017
desc = MongoDB Database
```

---

## 💻 CLI Commands

```bash
# Check status, memory, PID, ports & auto-heal dead services
mgr

# Output clean JSON (for scripts & CI/CD)
mgr --json

# Restart specific services (or all if omitted)
mgr restart api db
mgr up

# Stop services
mgr stop api
mgr down

# Tail live journal logs
mgr logs api
mgr logs api 100    # fetch last 100 lines

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

## 🤖 Model Context Protocol (MCP) for AI Agents

`mgr` includes a built-in standard **MCP Server (`mgr mcp`)** that allows AI Coding Agents (Claude Desktop, Cursor, Windsurf, Antigravity) to inspect, manage, and debug your Linux services directly.

### Exposed MCP Tools:

| Tool | Parameters | Description |
| :--- | :--- | :--- |
| `list_services` | `auto_heal: bool` | Returns live status, PID, memory (MB), ports, and system RAM |
| `restart_service` | `service?: string` | Restarts a specific service (or all) |
| `stop_service` | `service?: string` | Gracefully stops a service |
| `kill_service` | `service?: string` | Force terminates (`SIGKILL`) a service |
| `get_service_logs`| `service: string, lines?: int` | Retrieves recent journal logs for debugging |
| `auto_heal_services`| | Scans and restarts any dead or failed services |

### How to Connect:

#### 1. Claude Desktop (`claude_desktop_config.json`)
```json
{
  "mcpServers": {
    "mgr": {
      "command": "ssh",
      "args": ["your-server", "mgr", "mcp"]
    }
  }
}
```

#### 2. Cursor / Windsurf (`mcp_config.json`)
```json
{
  "mcpServers": {
    "system-manager": {
      "command": "mgr",
      "args": ["mcp"]
    }
  }
}
```

---

## 🛡️ Auto-Healing Watchdog

`mgr` provides two layers of 24/7 self-healing protection:

1. **Systemd Level:** If configured with `Restart=always`, systemd automatically revives crashed processes within seconds.
2. **Cron Watchdog (`mgr -w`):** Runs every 1 minute via `/etc/cron.d/mgr-watchdog`. If any service is detected as dead or failed, it automatically restarts it and logs the incident to `/var/log/mgr-watchdog.log`.

```bash
# Enable or disable the cron watchdog anytime:
sudo mgr install-watchdog
sudo mgr uninstall-watchdog
```

---

## ⚙️ Configuration Search Order

`mgr` searches for `mgr.conf` in the following order:

1. `$MGR_CONFIG` *(Environment variable)*
2. `./mgr.conf` or `./mgr.ini` *(Current working directory)*
3. `~/.config/mgr/mgr.conf` *(User directory)*
4. `/etc/mgr/mgr.conf` *(Global config directory)*
5. `/etc/mgr.conf` *(System config)*

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

Developed with ❤️ by [poqob](https://github.com/poqob) & [DagSolution](https://dagsolution.com).
