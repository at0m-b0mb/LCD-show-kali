#!/bin/bash
# OS Detection Utility for LCD-show
# Detects Raspbian, Kali Linux, Parrot OS, and other Debian-based systems
# Also detects correct boot partition path

# Detect OS type
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID=$ID
        OS_ID_LIKE=$ID_LIKE
        OS_NAME=$NAME
    else
        OS_ID="unknown"
        OS_ID_LIKE=""
        OS_NAME="Unknown"
    fi
    
    # Check for specific distributions
    if [ "$OS_ID" = "kali" ] || echo "$OS_NAME" | grep -qi "kali"; then
        echo "kali"
    elif [ "$OS_ID" = "parrot" ] || echo "$OS_NAME" | grep -qi "parrot"; then
        echo "parrot"
    elif [ "$OS_ID" = "raspbian" ] || echo "$OS_NAME" | grep -qi "raspbian"; then
        echo "raspbian"
    elif echo "$OS_ID_LIKE" | grep -q "debian"; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Detect boot partition path
detect_boot_path() {
    # Check if /boot/firmware exists (new Raspberry Pi OS / Kali Linux style)
    if [ -d /boot/firmware ] && [ -f /boot/firmware/config.txt ]; then
        echo "/boot/firmware"
    # Check if /boot/config.txt exists (old Raspbian style)
    elif [ -f /boot/config.txt ]; then
        echo "/boot"
    else
        # Default to /boot/firmware for newer systems
        echo "/boot/firmware"
    fi
}

# Detect overlays path
detect_overlays_path() {
    BOOT_PATH=$(detect_boot_path)
    if [ -d "$BOOT_PATH/overlays" ]; then
        echo "$BOOT_PATH/overlays"
    else
        echo "$BOOT_PATH/overlays"
    fi
}

# Get appropriate package manager repository
get_package_repo() {
    OS_TYPE=$(detect_os)
    case "$OS_TYPE" in
        kali)
            echo "kali"
            ;;
        parrot)
            echo "parrot"
            ;;
        raspbian)
            echo "raspbian"
            ;;
        *)
            echo "debian"
            ;;
    esac
}

# Main function to export all detected values
export_os_info() {
    export DETECTED_OS=$(detect_os)
    export BOOT_PATH=$(detect_boot_path)
    export OVERLAYS_PATH=$(detect_overlays_path)
    export PACKAGE_REPO=$(get_package_repo)
}

# If script is sourced, export variables
# If script is executed, print values
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Script is being executed
    echo "OS Type: $(detect_os)"
    echo "Boot Path: $(detect_boot_path)"
    echo "Overlays Path: $(detect_overlays_path)"
    echo "Package Repo: $(get_package_repo)"
else
    # Script is being sourced
    export_os_info
fi
