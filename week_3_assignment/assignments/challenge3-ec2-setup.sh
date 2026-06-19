#!/usr/bin/env bash
#
# challenge3-ec2-setup.sh
# -----------------------
# Fully prepares a fresh EC2 instance (Ubuntu/Debian or Amazon Linux):
#   1. updates packages
#   2. installs Docker
#   3. installs nginx
#   4. configures the firewall (ufw or firewalld)
#   5. clones a GitHub repo
#   6. deploys the app (docker compose if present, else a static nginx site)
#
# Usage:
#   sudo ./challenge3-ec2-setup.sh https://github.com/you/your-repo.git
#
set -euo pipefail

# ----------------------------- CONFIG -----------------------------
REPO_URL="${1:-}"
APP_DIR="/opt/app"
DEPLOY_USER="${SUDO_USER:-$(whoami)}"
OPEN_PORTS=(22 80 443)
# ------------------------------------------------------------------

[[ "$(id -u)" -eq 0 ]] || { echo "Run as root (sudo)."; exit 1; }
[[ -n "$REPO_URL" ]] || { echo "Usage: $0 <github-repo-url>"; exit 1; }

log() { echo -e "\n\033[1;34m==> $*\033[0m"; }

# --- Detect package manager ----------------------------------------
if command -v apt-get >/dev/null; then
    PKG="apt"
elif command -v dnf >/dev/null; then
    PKG="dnf"
elif command -v yum >/dev/null; then
    PKG="yum"
else
    echo "Unsupported distro (no apt/dnf/yum)."; exit 1
fi
log "Detected package manager: $PKG"

# --- 1. Update packages --------------------------------------------
log "Updating system packages..."
case "$PKG" in
    apt) export DEBIAN_FRONTEND=noninteractive
         apt-get update -y && apt-get upgrade -y
         apt-get install -y ca-certificates curl git gnupg lsb-release ;;
    dnf) dnf update -y && dnf install -y ca-certificates curl git ;;
    yum) yum update -y && yum install -y ca-certificates curl git ;;
esac

# --- 2. Install Docker ---------------------------------------------
if command -v docker >/dev/null; then
    log "Docker already installed: $(docker --version)"
else
    log "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
    usermod -aG docker "$DEPLOY_USER" || true
    log "Docker installed; $DEPLOY_USER added to the docker group (re-login to apply)."
fi

# --- 3. Install nginx ----------------------------------------------
if command -v nginx >/dev/null; then
    log "nginx already installed."
else
    log "Installing nginx..."
    case "$PKG" in
        apt) apt-get install -y nginx ;;
        dnf) dnf install -y nginx ;;
        yum) yum install -y nginx ;;
    esac
fi
systemctl enable --now nginx

# --- 4. Configure firewall -----------------------------------------
log "Configuring firewall..."
if command -v ufw >/dev/null; then
    for p in "${OPEN_PORTS[@]}"; do ufw allow "$p"/tcp; done
    ufw --force enable
    log "ufw enabled; open ports: ${OPEN_PORTS[*]}"
elif command -v firewall-cmd >/dev/null; then
    systemctl enable --now firewalld
    for p in "${OPEN_PORTS[@]}"; do firewall-cmd --permanent --add-port="${p}/tcp"; done
    firewall-cmd --reload
    log "firewalld configured; open ports: ${OPEN_PORTS[*]}"
else
    log "No ufw/firewalld found — skipping firewall (configure your EC2 Security Group instead)."
fi

# --- 5. Clone the repo ---------------------------------------------
log "Cloning $REPO_URL into $APP_DIR..."
if [[ -d "$APP_DIR/.git" ]]; then
    git -C "$APP_DIR" pull
else
    rm -rf "$APP_DIR"
    git clone "$REPO_URL" "$APP_DIR"
fi
chown -R "$DEPLOY_USER":"$DEPLOY_USER" "$APP_DIR" || true

# --- 6. Deploy the app ---------------------------------------------
log "Deploying application..."
cd "$APP_DIR"
if [[ -f docker-compose.yml || -f compose.yaml ]]; then
    log "Found a compose file — bringing the stack up with Docker Compose."
    docker compose up -d
elif [[ -f Dockerfile ]]; then
    log "Found a Dockerfile — building and running the image."
    docker build -t app:latest .
    docker rm -f app 2>/dev/null || true
    docker run -d --name app --restart unless-stopped -p 8080:80 app:latest
    log "Container running on host port 8080."
else
    log "No Docker setup found — serving repo contents as a static nginx site."
    rm -rf /var/www/html
    ln -sfn "$APP_DIR" /var/www/html
    systemctl restart nginx
fi

log "Setup complete!"
echo "  - nginx:  $(systemctl is-active nginx)"
echo "  - docker: $(systemctl is-active docker 2>/dev/null || echo n/a)"
echo "  - app at: http://$(curl -fsS --max-time 3 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')/"
