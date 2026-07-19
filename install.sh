#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# brūhi Cloud — Install Script
# Usage: bash install.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

DEPLOY_REPO="https://raw.githubusercontent.com/bruhi-technologies/bruhi-deploy/main"
INSTALL_DIR="${BRUHI_DIR:-$HOME/bruhi-cloud}"

echo ""
echo "  brūhi Cloud — Self-Hosted Installer"
echo "  ────────────────────────────────────"
echo ""

# ── 1. Check dependencies ─────────────────────────────────────
for cmd in docker curl; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌  $cmd is not installed. Please install it and re-run."
    exit 1
  fi
done

# Check Docker Compose plugin
if ! docker compose version &>/dev/null; then
  echo "❌  Docker Compose plugin not found. Please install Docker Desktop or 'docker-compose-plugin'."
  exit 1
fi

echo "✅  Docker and Docker Compose found."

# ── 2. Create install directory ───────────────────────────────
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
echo "📁  Installing to: $INSTALL_DIR"

# ── 3. Download files ─────────────────────────────────────────
echo "⬇️   Downloading docker-compose.yml..."
curl -fsSL "$DEPLOY_REPO/docker-compose.yml" -o docker-compose.yml

echo "⬇️   Downloading Caddyfile..."
curl -fsSL "$DEPLOY_REPO/Caddyfile" -o Caddyfile

if [ ! -f .env ]; then
  echo "⬇️   Downloading .env.example..."
  curl -fsSL "$DEPLOY_REPO/.env.example" -o .env.example
  
  echo ""
  echo "⚙️   Configuring environment variables..."
  echo "    Press Enter to accept the default value shown in brackets."
  echo ""
  
  > .env
  
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
      echo "$line" >> .env
    else
      key=$(echo "$line" | cut -d= -f1)
      default_val=$(echo "$line" | cut -d= -f2-)
      
      read -p "    $key [$default_val]: " user_val
      
      if [ -z "$user_val" ]; then
        echo "$key=$default_val" >> .env
      else
        echo "$key=$user_val" >> .env
      fi
    fi
  done < .env.example
  
  rm .env.example

  echo ""
  echo "✅   Configuration saved to .env."
  echo ""
else
  echo "ℹ️   .env already exists — skipping."
fi

# ── 4. Pull the image ─────────────────────────────────────────
echo "🐳  Pulling brūhi Cloud image from GHCR..."
IMAGE=$(grep '^IMAGE=' .env | cut -d= -f2- | tr -d '"' || echo "ghcr.io/bruhi-technologies/bruhi-cloud:latest")
docker pull "${IMAGE:-ghcr.io/bruhi-technologies/bruhi-cloud:latest}"

echo ""
echo "✅  brūhi Cloud is ready!"
echo ""
echo "   Next steps:"
echo "   1. Start the stack:          cd $INSTALL_DIR && docker compose up -d"
echo "   2. Open in browser:          http://<your-server-ip>:8000"
echo ""
