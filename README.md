# 🎙️ brūhi Cloud

**Self-hosted radio automation & streaming platform.**

Manage multiple radio stations from one place — schedule playlists, take live shows via browser, and stream to your audience via Icecast. Everything runs in a single Docker container.

---

## ✨ Features

- 🎚️ **Multi-station management** — Independent stations, each with their own streams, schedule, and settings
- 🔴 **Live broadcasting** — WebRTC browser-to-air with low latency
- 🎵 **Automated playlists** — Upload audio, build playlists, schedule by time slot
- 📻 **Broadcasting outputs** — Stream directly to Icecast (bundled), Shoutcast, HLS, or RTP/UDP endpoints.
- 📁 **Media library** — Upload, organise, and manage all your audio files
- 🔁 **Smart fallback** — Automatic source switching: Live → Scheduled → Silence
- 🔒 **Passkey authentication** — Passwordless login via WebAuthn
- 🗄️ **Object storage support** — S3-compatible storage (AWS, Cloudflare R2, Backblaze B2, MinIO)
- 🔐 **HTTPS out of the box** — Caddy reverse proxy with automatic Let's Encrypt certificates

---

## 🚀 Quick Start

### Requirements

- Docker Engine 24+ with Docker Compose plugin
- A Linux server (or any OS running Docker)
- A domain name pointed at your server (for HTTPS)

### Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/bruhi-technologies/bruhi-deploy/main/install.sh)
```

The installer will guide you through the initial configuration and automatically generate your `.env` file.

Start the stack:

```bash
cd ~/bruhi-cloud
docker compose up -d
```

Open **http://<your-server-ip>:8000** (or your domain if using HTTPS).

---

## ⚙️ Configuration

All configuration is done via the `.env` file. Key settings:

| Variable           | Description                   | Default           |
| ------------------ | ----------------------------- | ----------------- |
| `BRUHI_URL`        | Public URL of your instance   | —                 |
| `DOMAIN`           | Domain name for HTTPS (Caddy) | —                 |
| `COMPOSE_PROFILES` | Active services — see below   | `bundled-icecast` |

*(Note: Storage and Email settings are now configured directly within the Admin Dashboard UI.)*

### Profiles

| Profile           | What it does                      |
| ----------------- | --------------------------------- |
| `bundled-icecast` | Starts a local Icecast container  |
| `proxy`           | Starts Caddy with automatic HTTPS |

**Example — HTTPS with bundled Icecast:**

```
COMPOSE_PROFILES=bundled-icecast,proxy
DOMAIN=radio.yourdomain.com
BRUHI_URL=https://radio.yourdomain.com
```

---

## 🐳 Docker Image

```
ghcr.io/bruhi-technologies/bruhi-cloud:latest
```

Pinning to a specific version is recommended for production:

```
ghcr.io/bruhi-technologies/bruhi-cloud:0.4.0
```

---

## 🔄 Updating

```bash
cd ~/bruhi-cloud
docker compose pull
docker compose up -d
```

---

## 🏗️ Stack

| Component       | Technology                   |
| --------------- | ---------------------------- |
| API & UI server | Python / FastAPI + SvelteKit |
| Audio engine    | Rust (bruhi-audio)           |
| Streaming       | Icecast 2                    |
| Reverse proxy   | Caddy 2                      |
| Database        | SQLite                       |
| Object storage  | S3-compatible (optional)     |

---

## 📄 License

Copyright © 2026 Bruhi Technologies. All rights reserved.  
This software is proprietary. See [LICENSE](LICENSE) for details.

---

**Built for live radio production · [bruhi.in](https://bruhi.in)**
