#!/bin/bash
set -e

echo "=============================================="
echo "   MHS35 TFT Installer for Kali Linux Pi 5"
echo "=============================================="

BOOTCFG="/boot/firmware/config.txt"
OVERLAY_DIR="/boot/firmware/overlays"

# ----------------------------
# 1. Safety Checks
# ----------------------------
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root:"
  echo "   sudo ./MHS35-PI5-show.sh"
  exit 1
fi

if ! grep -q "Raspberry Pi 5" /proc/device-tree/model 2>/dev/null; then
  echo "⚠️ Warning: This script is optimized for Raspberry Pi 5"
fi

# ----------------------------
# 2. Backup Boot Config
# ----------------------------
echo "[+] Backing up config.txt..."
cp "$BOOTCFG" "${BOOTCFG}.bak.$(date +%F-%H%M)"

# ----------------------------
# 3. Enable SPI, I2C, UART
# ----------------------------
echo "[+] Enabling SPI, I2C, UART..."

sed -i '/^dtparam=spi=/d' "$BOOTCFG"
sed -i '/^dtparam=i2c_arm=/d' "$BOOTCFG"
sed -i '/^enable_uart=/d' "$BOOTCFG"

echo "dtparam=spi=on"       >> "$BOOTCFG"
echo "dtparam=i2c_arm=on"  >> "$BOOTCFG"
echo "enable_uart=1"      >> "$BOOTCFG"

# ----------------------------
# 4. Install Overlay
# ----------------------------
if [ ! -f "./usr/mhs35-overlay.dtb" ]; then
  echo "❌ ERROR: Missing ./usr/mhs35-overlay.dtb"
  echo "Place this script inside the LCD-show folder."
  exit 1
fi

echo "[+] Installing MHS35 overlay..."
cp ./usr/mhs35-overlay.dtb "$OVERLAY_DIR/mhs35.dtbo"

sed -i '/dtoverlay=mhs35/d' "$BOOTCFG"
echo "dtoverlay=mhs35,rotate=90" >> "$BOOTCFG"

# ----------------------------
# 5. HDMI Safe Output
# ----------------------------
echo "[+] Forcing HDMI safe output..."
sed -i '/hdmi_force_hotplug/d' "$BOOTCFG"
echo "hdmi_force_hotplug=1" >> "$BOOTCFG"

# ----------------------------
# 6. Touch Calibration (X11)
# ----------------------------
echo "[+] Configuring touchscreen calibration..."

mkdir -p /etc/X11/xorg.conf.d

if [ -f "./usr/99-calibration.conf-mhs35-90" ]; then
  cp ./usr/99-calibration.conf-mhs35-90 \
     /etc/X11/xorg.conf.d/99-mhs35.conf
else
  cat <<EOF > /etc/X11/xorg.conf.d/99-mhs35.conf
Section "InputClass"
    Identifier "MHS35 Touch Calibration"
    MatchProduct "ADS7846 Touchscreen"
    Option "Calibration" "3900 200 3900 200"
    Option "SwapAxes" "1"
EndSection
EOF
fi

# ----------------------------
# 7. Remove Legacy Pi OS Drivers
# ----------------------------
echo "[+] Removing legacy drivers..."

rm -f /usr/share/X11/xorg.conf.d/99-fbturbo.conf
rm -f /usr/share/X11/xorg.conf.d/99-fbturbo-fbcp.conf
rm -f /usr/local/bin/fbcp
rm -f /etc/rc.local

# ----------------------------
# 8. Install Touch Input Driver
# ----------------------------
echo "[+] Installing X11 touch drivers..."

apt update
apt install -y xserver-xorg-input-evdev xinput

# ----------------------------
# 9. Disable Wayland (Force X11)
# ----------------------------
echo "[+] Disabling Wayland for touch compatibility..."

mkdir -p /etc/gdm3

cat <<EOF > /etc/gdm3/custom.conf
[daemon]
WaylandEnable=false
EOF

# ----------------------------
# 10. Sync & Reboot
# ----------------------------
sync
sync
sleep 2

echo "=============================================="
echo "✅ Installation Complete!"
echo "✅ System will reboot in 5 seconds"
echo "=============================================="

sleep 5
reboot
