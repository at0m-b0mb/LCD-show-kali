#!/usr/bin/env bash
set -e

echo "[*] MIS35 LCD Installer for Kali Linux"

# -------------------------------------------------
# Ensure root
# -------------------------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo ./install_mis35_kali.sh"
  exit 1
fi

# -------------------------------------------------
# Detect boot path (Kali vs RaspberryPi OS)
# -------------------------------------------------
if [ -d /boot/firmware ]; then
  BOOT_PATH="/boot/firmware"
else
  BOOT_PATH="/boot"
fi

CONFIG_FILE="$BOOT_PATH/config.txt"
CONFIG_BAK="$CONFIG_FILE.bak"

echo "[*] Using boot path: $BOOT_PATH"

# -------------------------------------------------
# Install required packages
# -------------------------------------------------
echo "[*] Installing required packages..."
apt update
apt install -y git cmake build-essential \
xserver-xorg-input-evdev libraspberrypi-dev

# -------------------------------------------------
# Backup config.txt
# -------------------------------------------------
if [ ! -f "$CONFIG_BAK" ]; then
  echo "[*] Backing up config.txt..."
  cp "$CONFIG_FILE" "$CONFIG_BAK"
fi

# -------------------------------------------------
# Ensure X11 config directory exists
# -------------------------------------------------
mkdir -p /etc/X11/xorg.conf.d

# -------------------------------------------------
# Install overlay file
# -------------------------------------------------
echo "[*] Installing LCD overlay..."
if [ -f ./usr/mis35-overlay.dtb ]; then
  mkdir -p "$BOOT_PATH/overlays"
  cp ./usr/mis35-overlay.dtb "$BOOT_PATH/overlays/mis35.dtbo"
else
  echo "[!] Overlay file not found: ./usr/mis35-overlay.dtb"
fi

# -------------------------------------------------
# Remove old LCD entries safely
# -------------------------------------------------
sed -i '/MIS35 LCD CONFIG/d' "$CONFIG_FILE"
sed -i '/dtoverlay=mis35/d' "$CONFIG_FILE"
sed -i '/hdmi_cvt 480 320/d' "$CONFIG_FILE"

# -------------------------------------------------
# Append clean LCD config
# -------------------------------------------------
cat <<EOF >> "$CONFIG_FILE"

# --- MIS35 LCD CONFIG ---
hdmi_force_hotplug=1
dtparam=i2c_arm=on
dtparam=spi=on
enable_uart=1
dtoverlay=mis35,rotate=90
hdmi_group=2
hdmi_mode=87
hdmi_cvt 480 320 60 6 0 0 0
hdmi_drive=2
# --- END MIS35 LCD CONFIG ---
EOF

# -------------------------------------------------
# Touch calibration
# -------------------------------------------------
if [ -f ./usr/99-calibration.conf-mis35-90 ]; then
  cp ./usr/99-calibration.conf-mis35-90 \
  /etc/X11/xorg.conf.d/99-calibration.conf
fi

# -------------------------------------------------
# Install evdev if missing
# -------------------------------------------------
if ! dpkg -l | grep -q xserver-xorg-input-evdev; then
  apt install -y xserver-xorg-input-evdev
  cp /usr/share/X11/xorg.conf.d/10-evdev.conf \
  /usr/share/X11/xorg.conf.d/45-evdev.conf
fi

# -------------------------------------------------
# Install fbcp (HDMI → DPI mirror)
# -------------------------------------------------
echo "[*] Installing fbcp..."

if ! command -v fbcp >/dev/null; then
  rm -rf rpi-fbcp
  git clone https://github.com/tasanakorn/rpi-fbcp
  mkdir rpi-fbcp/build
  cd rpi-fbcp/build
  cmake ..
  make -j$(nproc)
  install fbcp /usr/local/bin/fbcp
  cd ../..
fi

# -------------------------------------------------
# Create systemd service for fbcp
# -------------------------------------------------
cat <<EOF > /etc/systemd/system/fbcp.service
[Unit]
Description=Framebuffer Copy
After=multi-user.target

[Service]
ExecStart=/usr/local/bin/fbcp
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable fbcp

# -------------------------------------------------
# Optional rotation argument
# -------------------------------------------------
if [ $# -eq 1 ] && [ -x ./rotate.sh ]; then
  ./rotate.sh "$1"
fi

# -------------------------------------------------
# Final sync and reboot prompt
# -------------------------------------------------
sync

echo ""
echo "[✔] MIS35 LCD installation completed successfully!"
read -p "Reboot now? [Y/n]: " REBOOT
REBOOT=${REBOOT:-Y}

if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
  reboot
else
  echo "[*] Please reboot manually to activate the LCD."
fi
