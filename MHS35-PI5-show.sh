#!/bin/bash
set -e

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: This script must be run as root"
  echo "Usage: sudo $0"
  exit 1
fi

BOOTCFG="/boot/firmware/config.txt"
OVERLAY_DIR="/boot/firmware/overlays"

# Verify required files exist
if [ ! -f "./usr/mhs35-overlay.dtb" ]; then
  echo "ERROR: Missing ./usr/mhs35-overlay.dtb"
  echo "Please run this script from the LCD-show-kali directory"
  exit 1
fi

# Backup Boot Config
cp "$BOOTCFG" "${BOOTCFG}.bak.$(date +%F-%H%M)"

# Enable SPI, I2C, UART
sed -i '/^dtparam=spi=/d' "$BOOTCFG"
sed -i '/^dtparam=i2c_arm=/d' "$BOOTCFG"
sed -i '/^enable_uart=/d' "$BOOTCFG"

echo "dtparam=spi=on" >> "$BOOTCFG"
echo "dtparam=i2c_arm=on" >> "$BOOTCFG"
echo "enable_uart=1" >> "$BOOTCFG"

# Install Overlay
cp ./usr/mhs35-overlay.dtb "$OVERLAY_DIR/mhs35.dtbo"

sed -i '/dtoverlay=mhs35/d' "$BOOTCFG"
echo "dtoverlay=mhs35,rotate=90" >> "$BOOTCFG"

# Force HDMI Output
sed -i '/hdmi_force_hotplug/d' "$BOOTCFG"
echo "hdmi_force_hotplug=1" >> "$BOOTCFG"

# Configure Touchscreen (X11)
mkdir -p /etc/X11/xorg.conf.d

if [ -f "./usr/99-calibration.conf-mhs35-90" ]; then
  cp ./usr/99-calibration.conf-mhs35-90 /etc/X11/xorg.conf.d/99-mhs35.conf
else
  cat <<EOF > /etc/X11/xorg.conf.d/99-mhs35.conf
Section "InputClass"
    Identifier "MHS35 Touch Calibration"
    MatchProduct "ADS7846 Touchscreen"
    Option "Calibration" "3936 227 268 3880"
    Option "SwapAxes" "1"
    Option "EmulateThirdButton" "1"
    Option "EmulateThirdButtonTimeout" "1000"
    Option "EmulateThirdButtonMoveThreshold" "300"
EndSection
EOF
fi

# Remove Legacy Components
rm -f /usr/share/X11/xorg.conf.d/99-fbturbo.conf
rm -f /usr/share/X11/xorg.conf.d/99-fbturbo-fbcp.conf
rm -f /usr/local/bin/fbcp
rm -f /etc/rc.local

# Install X11 Touch Drivers
apt update
apt install -y xserver-xorg-input-evdev xinput

# Disable Wayland
mkdir -p /etc/gdm3
cat <<EOF > /etc/gdm3/custom.conf
[daemon]
WaylandEnable=false
EOF

# Sync and Reboot
sync
sync
sleep 1

reboot
