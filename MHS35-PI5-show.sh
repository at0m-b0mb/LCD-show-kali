#!/bin/bash

# Update repo and install required tools
sudo apt update
sudo apt install -y git cmake build-essential xserver-xorg-input-evdev libraspberrypi-dev

# Backup current system files if needed
sudo ./system_backup.sh

# Remove conflicting input config
sudo rm -f /etc/X11/xorg.conf.d/40-libinput.conf

# Ensure X11 config directory exists
sudo mkdir -p /etc/X11/xorg.conf.d

# Copy overlay files for the LCD
sudo cp ./usr/mhs35-overlay.dtb /boot/firmware/overlays/
sudo cp ./usr/mhs35-overlay.dtb /boot/firmware/overlays/mhs35.dtbo

# Patch config.txt
CONFIG_FILE="/boot/firmware/config.txt"
CONFIG_BAK="./boot/config.txt.bak"

cp $CONFIG_FILE $CONFIG_BAK

{
echo "hdmi_force_hotplug=1"
echo "dtparam=i2c_arm=on"
echo "dtparam=spi=on"
echo "enable_uart=1"
echo "dtoverlay=mhs35:rotate=90"
echo "hdmi_group=2"
echo "hdmi_mode=1"
echo "hdmi_mode=87"
echo "hdmi_cvt 480 320 60 6 0 0 0"
echo "hdmi_drive=2"
} >> $CONFIG_BAK

sudo cp -f $CONFIG_BAK $CONFIG_FILE

# Copy calibration and optional config files
sudo cp ./usr/99-calibration.conf-mhs35-90 /etc/X11/xorg.conf.d/99-calibration.conf

# If older Debian (< 12.1), add fbturbo config
source ./system_config.sh
if [[ "$deb_version" < "12.1" ]]; then
    sudo cp ./usr/99-fbturbo.conf /usr/share/X11/xorg.conf.d/
fi

# Optional: Install evdev driver
if ! dpkg -l | grep -q xserver-xorg-input-evdev; then
    sudo apt-get install -y xserver-xorg-input-evdev
    sudo cp /usr/share/X11/xorg.conf.d/10-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
fi

# Optional: Install FBCP (Framebuffer Copy for HDMI to TFT)
if command -v cmake > /dev/null; then
    sudo apt-get install -y cmake libraspberrypi-dev
    git clone https://github.com/tasanakorn/rpi-fbcp || cp -r ./usr/rpi-fbcp .
    mkdir -p rpi-fbcp/build && cd rpi-fbcp/build
    cmake .. && make
    sudo install fbcp /usr/local/bin/fbcp
    cd -
    sudo cp ./etc/rc.local /etc/rc.local
fi

sudo sync && sleep 1

# Rotate if argument passed
if [ $# -eq 1 ]; then
    sudo ./rotate.sh $1
elif [ $# -gt 1 ]; then
    echo "Too many parameters"
fi

# Restart The System
echo "[*] Driver installation complete. Reboot is required."
read -p "Reboot now? [Y/n]: " REBOOT
if [[ $REBOOT =~ ^[Yy]|""$ ]]; then
  echo "[*] Rebooting..."
  sudo reboot
else
  echo "[*] Please reboot manually afterwards."
fi