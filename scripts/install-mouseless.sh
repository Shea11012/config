#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="${BIN_DIR:-/usr/local/bin}"
SERVICE_DIR="${SERVICE_DIR:-/etc/systemd/system}"
CONFIG="${CONFIG:-$HOME/.config/mouseless/config.yaml}"
REPO="jbensmann/mouseless"

echo "==> fetching latest release from $REPO..."
LATEST=$(curl -sS "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST" ]; then
    echo "ERROR: failed to get latest release tag" >&2
    exit 1
fi
echo "    latest: $LATEST"

TAR="mouseless_linux_amd64.tar.gz"
URL="https://github.com/$REPO/releases/download/$LATEST/$TAR"

echo "==> downloading $TAR..."
TMPDIR=$(mktemp -d)
curl -sSL "$URL" -o "$TMPDIR/$TAR"

echo "==> extracting..."
tar -xzf "$TMPDIR/$TAR" -C "$TMPDIR"

echo "==> installing to $BIN_DIR/mouseless..."
sudo mv "$TMPDIR/mouseless" "$BIN_DIR/mouseless"
sudo chmod +x "$BIN_DIR/mouseless"

rm -rf "$TMPDIR"

echo "==> writing systemd service..."
sudo tee "$SERVICE_DIR/mouseless.service" > /dev/null <<EOF
[Unit]
Description=mouseless

[Service]
Type=simple
ExecStart=$BIN_DIR/mouseless --config $CONFIG

[Install]
WantedBy=multi-user.target
EOF

echo "==> enabling & starting service..."
sudo systemctl daemon-reload
sudo systemctl enable --now mouseless

echo ""
echo "done. mouseless $LATEST installed."
echo "    binary:  $BIN_DIR/mouseless"
echo "    config:  $CONFIG"
echo "    service: systemctl status mouseless"
