#!/bin/bash
# Common functions for LCD-show scripts
# Compatible with Raspbian, Kali Linux, Parrot OS, and other Debian-based systems

# Source OS detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/os-detect.sh"

# Get boot config path
get_boot_config() {
    echo "$BOOT_PATH/config.txt"
}

# Get cmdline path
get_cmdline_path() {
    echo "$BOOT_PATH/cmdline.txt"
}

# Copy overlay files with OS-aware path
copy_overlay() {
    local overlay_name=$1
    local source_file="./usr/${overlay_name}-overlay.dtb"
    
    if [ ! -f "$source_file" ]; then
        echo "Warning: Overlay source file not found: $source_file"
        return 1
    fi
    
    sudo cp "$source_file" "$OVERLAYS_PATH/"
    sudo cp "$source_file" "$OVERLAYS_PATH/${overlay_name}.dtbo"
    return 0
}

# Backup boot config
backup_boot_config() {
    local boot_config=$(get_boot_config)
    if [ -f "$boot_config" ]; then
        sudo cp -rf "$boot_config" ./.system_backup/
    fi
}

# Install package with OS-aware repository
install_package() {
    local package=$1
    local fallback_deb=$2
    
    # Try to install from repository first
    if sudo apt-get install -y "$package" 2> error_output.txt; then
        echo "Successfully installed $package from repository"
        return 0
    fi
    
    # If repository install failed and we have a fallback deb
    if [ -n "$fallback_deb" ] && [ -f "$fallback_deb" ]; then
        echo "Repository install failed, trying local package: $fallback_deb"
        if sudo dpkg -i -B "$fallback_deb" 2> error_output.txt; then
            echo "Successfully installed $package from local package"
            return 0
        fi
    fi
    
    # Check if there were errors
    result=$(cat ./error_output.txt)
    echo -e "\033[31m$result\033[0m"
    if grep -q "error:" ./error_output.txt; then
        return 1
    fi
    
    return 0
}

# Configure boot settings for LCD
configure_boot_for_lcd() {
    local overlay=$1
    local rotation=${2:-90}
    local hdmi_cvt=${3:-"480 320 60 6 0 0 0"}
    
    local boot_config=$(get_boot_config)
    local cmdline_path=$(get_cmdline_path)
    
    # Detect root device
    root_dev=$(grep -oPr "root=[^\s]*" "$cmdline_path" 2>/dev/null | awk -F= '{printf $NF}')
    
    # Create backup config
    if test "$root_dev" = "/dev/mmcblk0p7"; then
        sudo cp -rf ./boot/config-noobs-nomal.txt ./boot/config.txt.bak
    else
        sudo cp -rf ./boot/config-nomal.txt ./boot/config.txt.bak
        sudo echo "hdmi_force_hotplug=1" >> ./boot/config.txt.bak
    fi
    
    # Add LCD configuration
    sudo echo "dtparam=i2c_arm=on" >> ./boot/config.txt.bak
    sudo echo "dtparam=spi=on" >> ./boot/config.txt.bak
    sudo echo "enable_uart=1" >> ./boot/config.txt.bak
    sudo echo "dtoverlay=${overlay}:rotate=${rotation}" >> ./boot/config.txt.bak
    sudo echo "hdmi_group=2" >> ./boot/config.txt.bak
    sudo echo "hdmi_mode=1" >> ./boot/config.txt.bak
    sudo echo "hdmi_mode=87" >> ./boot/config.txt.bak
    sudo echo "hdmi_cvt $hdmi_cvt" >> ./boot/config.txt.bak
    sudo echo "hdmi_drive=2" >> ./boot/config.txt.bak
    
    # Copy to actual config location
    sudo cp -rf ./boot/config.txt.bak "$boot_config"
}

# Install fbcp with cmake
install_fbcp() {
    wget --spider -q -o /dev/null --tries=1 -T 10 https://cmake.org/
    if [ $? -eq 0 ]; then
        sudo apt-get update
        if install_package "cmake"; then
            type cmake > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                sudo rm -rf rpi-fbcp
                wget --spider -q -o /dev/null --tries=1 -T 10 https://github.com
                if [ $? -eq 0 ]; then
                    sudo git clone https://github.com/tasanakorn/rpi-fbcp
                    if [ $? -ne 0 ]; then
                        echo "download fbcp failed, copy native fbcp!!!"
                        sudo cp -r ./usr/rpi-fbcp .
                    fi
                else
                    echo "bad network, copy native fbcp!!!"
                    sudo cp -r ./usr/rpi-fbcp .
                fi
                sudo mkdir -p ./rpi-fbcp/build
                cd ./rpi-fbcp/build/
                sudo cmake ..
                sudo make
                sudo install fbcp /usr/local/bin/fbcp
                cd - > /dev/null
                type fbcp > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    sudo cp -rf ./usr/99-fbturbo-fbcp.conf /usr/share/X11/xorg.conf.d/99-fbturbo.conf
                    sudo cp -rf ./etc/rc.local /etc/rc.local
                    return 0
                fi
            else
                echo "install cmake error!!!!"
                return 1
            fi
        fi
    else
        echo "bad network, can't install cmake!!!"
        return 1
    fi
}

# Install evdev for touch support
install_evdev() {
    version=$(uname -v)
    version=${version##* }
    echo "Kernel version: $version"
    
    if test $version -lt 2017; then
        echo "Old kernel, skipping evdev update"
        return 0
    else
        echo "Installing/updating touch configuration (evdev)"
        
        # Try installing from repository first (works for all Debian-based systems)
        if install_package "xserver-xorg-input-evdev" "./xserver-xorg-input-evdev_1%3a2.10.6-1+b1_armhf.deb"; then
            if [ -f /usr/share/X11/xorg.conf.d/10-evdev.conf ]; then
                sudo cp -rf /usr/share/X11/xorg.conf.d/10-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
            fi
            return 0
        else
            echo "Failed to install evdev"
            return 1
        fi
    fi
}

# Print OS information
print_os_info() {
    echo "=========================================="
    echo "LCD-show: OS Detection"
    echo "=========================================="
    echo "Detected OS: $DETECTED_OS"
    echo "Boot Path: $BOOT_PATH"
    echo "Overlays Path: $OVERLAYS_PATH"
    echo "Package Repo: $PACKAGE_REPO"
    echo "=========================================="
}
