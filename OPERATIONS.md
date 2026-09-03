# 🛠️ brūhi Cloud — Operations & Maintenance Guide

> This guide applies to all production servers: **AWS EC2, AWS Lightsail, DigitalOcean, Hetzner, Linode**, or any Linux VPS. The steps are identical across all cloud providers.

---

## 📋 Table of Contents

1. [Updating to the Latest Version](#-updating-to-the-latest-version)
2. [Checking Server Status](#-checking-server-status)
3. [Viewing Logs](#-viewing-logs)
4. [Periodic Pruning & Disk Maintenance](#-periodic-pruning--disk-maintenance)
5. [Troubleshooting Common Errors](#-troubleshooting-common-errors)
6. [Password Management](#-password-management)
7. [Resetting the Admin Account](#-resetting-the-admin-account)
8. [Full Reset / Clean Install](#-full-reset--clean-install)
9. [Environment Variable Reference](#-environment-variable-reference)
10. [Useful Commands Cheat Sheet](#-useful-commands-cheat-sheet)

---

## 🔄 Updating to the Latest Version

> ⚠️ Always update `docker-compose.yml` **before** pulling the new image when a new release is announced.

The `~/bruhi-cloud` directory on production servers is **not a Git repository** — it was created by the install script. You need to manually refresh configuration files when updating.

### Step 1 — Update `docker-compose.yml`

```bash
cd ~/bruhi-cloud

# Download the latest docker-compose.yml from the deploy repo
curl -fsSL https://raw.githubusercontent.com/bruhi-technologies/bruhi-deploy/main/docker-compose.yml -o docker-compose.yml
```

### Step 2 — Pull and Deploy the New Image

```bash
cd ~/bruhi-cloud

# Pull the latest Docker image
docker compose pull

# Recreate and start containers (zero-downtime)
docker compose up -d

# Clean up dangling images from previous versions
docker image prune -f
```

### Step 3 — Verify it Started Correctly

```bash
docker compose ps
docker compose logs --tail=30 bruhi-cloud
```

You should see near the bottom:

```
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

## 🩺 Checking Server Status

```bash
cd ~/bruhi-cloud

# Show containers and health status
docker compose ps

# Quick health check
curl http://localhost:8000/healthz
```

Expected healthy response:

```json
{ "status": "ok" }
```

---

## 📜 Viewing Logs

```bash
cd ~/bruhi-cloud

# Live logs from all services
docker compose logs -f

# Only the brūhi API + audio engine
docker compose logs -f bruhi-cloud

# Only Icecast
docker compose logs -f icecast

# Last 100 lines (no follow)
docker compose logs --tail=100 bruhi-cloud
```

---

## 🧹 Periodic Pruning & Disk Maintenance

Over time, self-hosted Docker servers can run out of disk space due to:
1. **Dangling Docker images**: Each time you update via `docker compose pull`, previous image layers remain cached on disk.
2. **System journal logs (`journald`)**: Uncapped Linux OS logs can accumulate over months.

To prevent disk exhaustion, use the following maintenance practices.

### 1. Check Current Disk Usage

```bash
# Check filesystem free space
df -h

# Check Docker disk allocation (images, containers, volumes, build cache)
docker system df
```

### 2. Routine Pruning Commands

Run these safely at any time (they will **never** delete your audio files or database):

```bash
# Remove dangling/untagged Docker images from previous updates
docker image prune -f

# Remove stopped containers and build cache (keeps volumes safe)
docker system prune -f
```

> [!CAUTION]
> **NEVER use `docker system prune --volumes` or `docker system prune -a --volumes` on production.**
> The `--volumes` flag will delete persistent Docker volumes (including your database and uploaded audio files) if containers are temporarily stopped.

### 3. Automated Weekly Pruning (Cron Job)

To keep the server automatically maintained, set up a weekly cron job that prunes dangling images every Sunday at 2:00 AM:

```bash
# Add automated weekly image prune to crontab
(crontab -l 2>/dev/null; echo "0 2 * * 0 docker image prune -f >/dev/null 2>&1") | crontab -
```

To verify the cron job is active:
```bash
crontab -l
```

### 4. Cap Linux System Journal Logs

If your VPS root partition is still filling up, vacuum old systemd journal logs and set a permanent 200MB ceiling:

```bash
# Clean existing journal logs older than 7 days or larger than 200MB
sudo journalctl --vacuum-size=200M

# Enforce a permanent 200MB maximum in systemd configuration
sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee /etc/systemd/journald.conf.d/size.conf << 'EOF'
[Journal]
SystemMaxUse=200M
RuntimeMaxUse=50M
EOF
sudo systemctl restart systemd-journald
```

---

## 🚨 Troubleshooting Common Errors

### ❌ Error: `ICECAST_SOURCE_PASSWORD must be explicitly configured in production mode`

**Cause:** `ICECAST_SOURCE_PASSWORD` is missing or commented out in your `.env` file, and the app is running in production mode.

**Fix:**

```bash
cd ~/bruhi-cloud
nano .env
```

Ensure these three lines are present and uncommented:

```env
ICECAST_SOURCE_PASSWORD=your_secure_password
ICECAST_ADMIN_PASSWORD=your_secure_password
ICECAST_RELAY_PASSWORD=your_secure_password
```

Or auto-generate secure passwords and append to `.env`:

```bash
echo "ICECAST_SOURCE_PASSWORD=$(openssl rand -hex 16)" >> .env
echo "ICECAST_ADMIN_PASSWORD=$(openssl rand -hex 16)" >> .env
echo "ICECAST_RELAY_PASSWORD=$(openssl rand -hex 16)" >> .env
```

Then restart:

```bash
docker compose up -d
```

---

### ❌ Error: `fatal: not a git repository`

**Cause:** The `~/bruhi-cloud` directory on production servers is not a Git repo — it was created by `install.sh`, not `git clone`.

**Fix:** Use `curl` to update files instead of `git pull`:

```bash
cd ~/bruhi-cloud
curl -fsSL https://raw.githubusercontent.com/bruhi-technologies/bruhi-deploy/main/docker-compose.yml -o docker-compose.yml
docker compose pull
docker compose up -d
```

---

### ❌ Error: `error while interpolating...ICECAST_SOURCE_PASSWORD: required variable is missing`

**Cause:** Running `docker compose pull` or `docker compose up` before setting Icecast passwords in `.env`.

**Fix:** Set the Icecast passwords in `.env` first (see above), then run:

```bash
docker compose pull
docker compose up -d
```

---

### ❌ Error: `Permission denied: /tmp/bruhi-audio/api_token`

**Cause:** Docker mounted the `bruhi_audio_sockets` volume with root ownership, preventing the `bruhi` user from writing to it. Fixed in **v0.10.1**.

**Fix:** Update to v0.10.1+ using the steps above. The new image includes a startup script that automatically corrects permissions.

If already on v0.10.1+ and still seeing this error:

```bash
docker compose exec bruhi-cloud chown -R bruhi:bruhi /tmp/bruhi-audio
docker compose restart bruhi-cloud
```

---

### ❌ Container keeps restarting (crash loop)

```bash
# Check logs for the actual error
docker compose logs --tail=50 bruhi-cloud

# Check container status and restart count
docker compose ps
```

Common causes and fixes:

| Cause                    | Fix                                                              |
| ------------------------ | ---------------------------------------------------------------- |
| Missing env variable     | Check `.env` — add missing variable, then `docker compose up -d` |
| Port 8000 already in use | Run `sudo lsof -i :8000`, change `PORT=` in `.env`               |
| Database corruption      | See [Full Reset](#-full-reset--clean-install)                    |
| Wrong image tag          | Check `IMAGE=` in `.env`, run `docker compose pull`              |

---

### ❌ Can't access the web UI

```bash
# Is the container running?
docker compose ps

# Is it listening on the port?
curl http://localhost:8000/healthz

# Check firewall (Ubuntu/Debian)
sudo ufw status
sudo ufw allow 8000/tcp

# Check firewall (AWS EC2 / Lightsail)
# Open port 8000 in Security Groups / Firewall rules in the AWS console
```

---

### ❌ Icecast stream not working

```bash
# Check icecast container logs
docker compose logs icecast

# Verify icecast is responding
curl http://localhost:8010/status.xsl
```

Checklist:

- `COMPOSE_PROFILES=bundled-icecast` is set in `.env`
- `ICECAST_SOURCE_PASSWORD` in `.env` matches what's configured in **Admin → Stations → Outputs**
- Port 8010 is open in your firewall / security group

---

### ❌ High CPU usage (~100%) or `rsyslogd` / `journald` spinning

**Cause:** If the server disk reaches 100% full (or system logs grow uncontrolled), `rsyslogd` fails to write log messages with `No space left on device` and enters an infinite retry spin loop consuming ~100% CPU.

**Fix:**

```bash
# 1. Check disk space and prune unused Docker data
df -h
docker system prune -a --volumes -f

# 2. Vacuum old journal logs and configure permanent size caps
sudo journalctl --vacuum-time=1d
sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee /etc/systemd/journald.conf.d/size.conf > /dev/null << 'EOF'
[Journal]
SystemMaxUse=200M
RuntimeMaxUse=50M
EOF

# 3. Restart logging daemons to stop the spinning process
sudo systemctl restart systemd-journald
sudo systemctl restart rsyslog

# 4. Make sure docker-compose.yml has log rotation configured (included in latest release)
curl -fsSL https://raw.githubusercontent.com/bruhi-technologies/bruhi-deploy/main/docker-compose.yml -o docker-compose.yml
docker compose up -d
```

---

## 🔐 Password Management

### Changing Icecast Passwords

1. Edit `.env`:

```bash
cd ~/bruhi-cloud
nano .env
```

2. Change the password values:

```env
ICECAST_SOURCE_PASSWORD=new_strong_password
ICECAST_ADMIN_PASSWORD=new_strong_password
ICECAST_RELAY_PASSWORD=new_strong_password
```

3. Restart to apply:

```bash
docker compose up -d
```

> ⚠️ After changing `ICECAST_SOURCE_PASSWORD`, update any broadcast outputs in the brūhi UI via **Admin → Stations → Outputs** to use the new password.

---

## 👤 Resetting the Admin Account

### ✅ Option 1 — Reset password using the built-in script (recommended)

A `reset_password.py` script is built into the container. Use it to reset any user's password without touching the database directly.

```bash
# Reset password for a specific account
docker compose exec bruhi-cloud python3 /app/server/reset_password.py admin@yourdomain.com new_password_here
```

Expected output:

```
Success: Password for 'admin@yourdomain.com' reset successfully.
```

If the email is wrong:

```
Error: User with email 'wrong@email.com' not found.
```

---

### Option 2 — Pre-seed on first boot (fresh install / no users exist)

If no users exist yet, add to `.env` before starting:

```env
BRUHI_ADMIN_EMAIL=admin@yourdomain.com
BRUHI_ADMIN_PASSWORD=your_new_password
```

Start normally — the account is created once on first boot only. After logging in, remove these lines from `.env`.

---

### Option 3 — Wipe all users and start fresh

```bash
cd ~/bruhi-cloud

# Delete all users from the database
docker compose exec bruhi-cloud python3 -c "
import sqlite3
conn = sqlite3.connect('/app/data/bruhi.db')
conn.execute('DELETE FROM users')
conn.commit()
print('All users deleted.')
"

# Then restart
docker compose restart bruhi-cloud
```

After this, go to the web UI — you'll be prompted to create the first owner account.

---

## 🔁 Full Reset / Clean Install

> ⚠️ **This deletes all data** — stations, playlists, audio files, settings. Use as a last resort.

```bash
cd ~/bruhi-cloud

# Stop and remove all containers AND volumes
docker compose down -v

# Start fresh
docker compose up -d
```

**To reset only the database (keep audio files):**

```bash
cd ~/bruhi-cloud
docker compose down
docker volume rm bruhi-cloud_bruhi_db
docker compose up -d
```

**To keep everything but restart containers:**

```bash
cd ~/bruhi-cloud
docker compose restart
```

---

## 📁 Environment Variable Reference

File location: `~/bruhi-cloud/.env`

| Variable                  | Required | Default        | Description                                              |
| ------------------------- | -------- | -------------- | -------------------------------------------------------- |
| `COMPOSE_PROFILES`        | ✅       | —              | `bundled-icecast,proxy` or `proxy`                       |
| `IMAGE`                   | ✅       | `latest`       | Docker image tag to deploy                               |
| `BRUHI_URL`               | ✅       | —              | Public URL e.g. `https://radio.yourdomain.com`           |
| `DOMAIN`                  | ✅       | —              | Domain for Caddy auto-HTTPS                              |
| `BRUHI_RP_ID`             | ✅       | —              | Hostname only (no https://) for passkeys                 |
| `ICECAST_SOURCE_PASSWORD` | ✅       | —              | Icecast source streaming password                        |
| `ICECAST_ADMIN_PASSWORD`  | ✅       | —              | Icecast admin password                                   |
| `ICECAST_RELAY_PASSWORD`  | ✅       | —              | Icecast relay password                                   |
| `BRUHI_ICECAST_MODE`      | ⬜       | `bundled`      | `bundled` or `external`                                  |
| `BRUHI_ADMIN_EMAIL`       | ⬜       | —              | Seed owner email (first boot only, if no users exist)    |
| `BRUHI_ADMIN_PASSWORD`    | ⬜       | —              | Seed owner password (first boot only, if no users exist) |
| `BRUHI_AUDIO_API_TOKEN`   | ⬜       | auto-generated | Internal API token between Python and Rust audio engine  |
| `PORT`                    | ⬜       | `8000`         | Host port for web UI                                     |
| `LOG_LEVEL`               | ⬜       | `warning`      | `debug` / `info` / `warning` / `error`                   |
| `CORS_ORIGINS`            | ⬜       | —              | Space-separated extra allowed CORS origins               |

---

## 📦 Useful Commands Cheat Sheet

```bash
# ── Status ─────────────────────────────────────────────────────
docker compose ps                          # container status
docker compose logs -f bruhi-cloud         # live logs
curl http://localhost:8000/healthz         # health check

# ── Lifecycle ──────────────────────────────────────────────────
docker compose up -d                       # start
docker compose down                        # stop
docker compose restart bruhi-cloud         # restart one service

# ── Update ─────────────────────────────────────────────────────
curl -fsSL https://raw.githubusercontent.com/bruhi-technologies/bruhi-deploy/main/docker-compose.yml -o docker-compose.yml
docker compose pull
docker compose up -d
docker image prune -f                      # prune old image versions

# ── Maintenance & Disk ─────────────────────────────────────────
df -h                                      # check free disk space
docker system df                           # check docker disk usage
docker image prune -f                      # prune dangling images
docker system prune -f                     # prune stopped containers & cache (safe)

# ── Shell access ───────────────────────────────────────────────
docker compose exec bruhi-cloud bash       # shell into container
docker compose exec bruhi-cloud sqlite3 /app/data/bruhi.db  # DB CLI (v0.10.2+)
docker compose exec bruhi-cloud python3 -c "import sqlite3; conn=sqlite3.connect('/app/data/bruhi.db'); [print(r) for r in conn.execute('SELECT id, email, role FROM users')]"  # Python (all versions)

# ── Reset volumes ──────────────────────────────────────────────
docker compose down -v                     # delete ALL volumes (full reset)
docker volume rm bruhi-cloud_bruhi_db      # delete only the database
```

---

_Works identically on: AWS EC2, AWS Lightsail, DigitalOcean Droplets, Hetzner Cloud, Linode/Akamai, Vultr, Oracle Cloud Free Tier, or any Linux VPS with Docker installed._

**brūhi Technologies · [bruhi.in](https://bruhi.in)**
