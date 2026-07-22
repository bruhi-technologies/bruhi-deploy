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
  echo ""
  
  # Parse default values from .env.example
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ ! "$line" =~ ^#.*$ ]] && [[ "$line" =~ = ]]; then
      key=$(echo "$line" | cut -d= -f1)
      val=$(echo "$line" | cut -d= -f2-)
      declare "DEFAULT_$key=$val"
    fi
  done < .env.example

  # 1. Ask for Docker Compose Profiles
  read -p "    Use bundled Icecast server? (y/n) [y]: " use_icecast

  if [[ ! "$use_icecast" =~ ^[nN]$ ]]; then
    profiles="bundled-icecast,proxy"
  else
    profiles="proxy"
  fi

  # 2. Ask for Port
  default_port="${DEFAULT_PORT:-8000}"
  read -p "    Port for the web interface [$default_port]: " user_port
  PORT="${user_port:-$default_port}"

  # 3. Ask for Domain (HTTPS reverse proxy is mandatory)
  default_domain="${DEFAULT_DOMAIN:-radio.yourdomain.com}"
  while true; do
    read -p "    Enter your domain name (e.g. radio.yourdomain.com) [$default_domain]: " user_domain
    domain="${user_domain:-$default_domain}"
    if [ -n "$domain" ]; then
      break
    fi
  done
  # Strip protocol (http:// or https://), port, and trailing path
  domain=$(echo "$domain" | sed -e 's|^[^/]*//||' | cut -d/ -f1 | cut -d: -f1)
  
  DOMAIN="$domain"
  BRUHI_URL="https://$domain"
  BRUHI_RP_ID="$domain"

  # Write .env file preserving formatting and comments of .env.example
  > .env
  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
      echo "$line" >> .env
    elif [[ "$line" =~ = ]]; then
      key=$(echo "$line" | cut -d= -f1)
      
      if [ "$key" = "COMPOSE_PROFILES" ]; then
        echo "COMPOSE_PROFILES=$profiles" >> .env
      elif [ "$key" = "PORT" ]; then
        echo "PORT=$PORT" >> .env
      elif [ "$key" = "DOMAIN" ]; then
        echo "DOMAIN=$DOMAIN" >> .env
      elif [ "$key" = "BRUHI_URL" ]; then
        echo "BRUHI_URL=$BRUHI_URL" >> .env
      elif [ "$key" = "BRUHI_RP_ID" ]; then
        echo "BRUHI_RP_ID=$BRUHI_RP_ID" >> .env
      else
        # Copy the default value from .env.example
        var_name="DEFAULT_$key"
        val="${!var_name}"
        echo "$key=$val" >> .env
      fi
    else
      echo "$line" >> .env
    fi
  done < .env.example

  rm .env.example

  echo ""
  echo "✅  Configuration saved to .env:"
  echo "    - Profiles:         $profiles"
  echo "    - Port:             $PORT"
  echo "    - Public URL:       $BRUHI_URL"
  echo "    - Domain:           $DOMAIN"
  echo "    - Passkey RP ID:    $BRUHI_RP_ID"
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
echo "   2. Open in browser:          https://${DOMAIN:-<your-domain>}"
echo ""
