#!/bin/bash
# Source OS detection to get dynamic boot paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/os-detect.sh"

if [ ! -d "./.system_backup" ]; then
sudo mkdir ./.system_backup
fi

sudo rm -rf ./.system_backup/*

if [ -f /etc/X11/xorg.conf.d/99-calibration.conf ]; then
sudo cp -rf /etc/X11/xorg.conf.d/99-calibration.conf ./.system_backup
sudo rm -rf /etc/X11/xorg.conf.d/99-calibration.conf
fi

if [ -f /etc/X11/xorg.conf.d/40-libinput.conf ]; then
sudo cp -rf /etc/X11/xorg.conf.d/40-libinput.conf ./.system_backup
sudo rm -rf /etc/X11/xorg.conf.d/40-libinput.conf
fi

if [ -d /etc/X11/xorg.conf.d ]; then
sudo mkdir -p ./.system_backup/xorg.conf.d
sudo rm -rf /etc/X11/xorg.conf.d
fi

# Use dynamic boot path
BOOT_CONFIG="$BOOT_PATH/config.txt"
BOOT_CMDLINE="$BOOT_PATH/cmdline.txt"

result=`grep -rn "^dtoverlay=" "$BOOT_CONFIG" 2>/dev/null | grep ":rotate=" | tail -n 1`
if [ $? -eq 0 ]; then
str=`echo -n $result | awk -F: '{printf $2}' | awk -F= '{printf $NF}'`
if [ -f "$OVERLAYS_PATH/$str-overlay.dtb" ]; then
sudo cp -rf "$OVERLAYS_PATH/$str-overlay.dtb" ./.system_backup
sudo rm -rf "$OVERLAYS_PATH/$str-overlay.dtb"
fi
if [ -f "$OVERLAYS_PATH/$str.dtbo" ]; then
sudo cp -rf "$OVERLAYS_PATH/$str.dtbo" ./.system_backup
sudo rm -rf "$OVERLAYS_PATH/$str.dtbo"
fi
fi

root_dev=`grep -oPr "root=[^\s]*" "$BOOT_CMDLINE" 2>/dev/null | awk -F= '{printf $NF}'`
sudo cp -rf "$BOOT_CONFIG" ./.system_backup 2>/dev/null
sudo cp -rf "$BOOT_CMDLINE" ./.system_backup/ 2>/dev/null
if test "$root_dev" = "/dev/mmcblk0p7";then
sudo cp -rf ./boot/config-noobs-nomal.txt "$BOOT_CONFIG"
#sudo cp -rf ./usr/cmdline.txt-noobs-original "$BOOT_CMDLINE"
else
sudo cp -rf ./boot/config-nomal.txt "$BOOT_CONFIG"
#sudo cp -rf ./usr/cmdline.txt-original "$BOOT_CMDLINE"
fi
if [ -f /usr/share/X11/xorg.conf.d/99-fbturbo.conf ]; then
sudo cp -rf /usr/share/X11/xorg.conf.d/99-fbturbo.conf ./.system_backup/
fi
sudo cp -rf ./usr/99-fbturbo.conf-original /usr/share/X11/xorg.conf.d/99-fbturbo.conf
sudo cp -rf /etc/rc.local ./.system_backup/
sudo cp -rf ./etc/rc.local-original /etc/rc.local

sudo cp -rf /etc/modules ./.system_backup/
sudo cp -rf ./etc/modules-original /etc/modules

if [ -f /etc/modprobe.d/fbtft.conf ]; then
sudo cp -rf /etc/modprobe.d/fbtft.conf ./.system_backup
sudo rm -rf /etc/modprobe.d/fbtft.conf
fi

if [ -f /etc/inittab ]; then
sudo cp -rf /etc/inittab ./.system_backup
sudo rm -rf /etc/inittab
fi

type fbcp > /dev/null 2>&1
if [ $? -eq 0 ]; then
sudo touch ./.system_backup/have_fbcp
sudo rm -rf /usr/local/bin/fbcp
fi

#type cmake > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#sudo touch ./.system_backup/have_cmake
#sudo apt-get purge cmake -y 2> error_output.txt
#result=`cat ./error_output.txt`
#echo -e "\033[31m$result\033[0m"
#fi

if [ -f /usr/share/X11/xorg.conf.d/10-evdev.conf ]; then
sudo cp -rf /usr/share/X11/xorg.conf.d/10-evdev.conf ./.system_backup
sudo dpkg -P xserver-xorg-input-evdev
#sudo apt-get purge xserver-xorg-input-evdev -y  2> error_output.txt
#result=`cat ./error_output.txt`
#echo -e "\033[31m$result\033[0m"
fi

if [ -f /usr/share/X11/xorg.conf.d/45-evdev.conf ]; then
sudo cp -rf /usr/share/X11/xorg.conf.d/45-evdev.conf ./.system_backup
sudo rm -rf /usr/share/X11/xorg.conf.d/45-evdev.conf
fi

if [ -f ./.have_installed ]; then
sudo cp -rf ./.have_installed ./.system_backup
sudo rm -rf ./.have_installed
fi
