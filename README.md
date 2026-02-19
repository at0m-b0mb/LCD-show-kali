# LCD Display Driver for Raspberry Pi (Multi-OS Support)

This repository contains installation scripts for enabling **SPI TFT touchscreen displays** on **Raspberry Pi** devices running **Kali Linux**, **Parrot OS**, **Raspbian**, and other **Debian-based operating systems**.

> 🛠️ Originally forked from [GoodTFT's LCD-show](https://github.com/goodtft/LCD-show)  
> 💻 Enhanced by [@at0m-b0mb](https://github.com/at0m-b0mb) for multi-OS compatibility  
> 📦 Includes framebuffer mirroring (`fbcp`), calibration, and rotation support

---

## 🚀 Features

- ✅ **Multi-OS Support**: Works with Kali Linux, Parrot OS, Raspbian, and other Debian-based systems
- ✅ **Automatic OS Detection**: Detects your operating system and boot partition automatically
- ✅ **Boot Path Detection**: Supports both `/boot/` (old style) and `/boot/firmware/` (new style)
- ✅ Tested on **Raspberry Pi 5** and other Raspberry Pi models
- ✅ Supports multiple LCD models (MHS35, LCD35, LCD7B, and many more)
- ✅ Installs required drivers and device overlays
- ✅ Enables touch and display output via SPI
- ✅ Optional framebuffer mirroring via `fbcp`
- ⚠️ Rotation is **not fully functional yet** on some setups — work in progress

---

## 📦 Requirements

- Raspberry Pi (any model supporting SPI displays)
- One of the following operating systems:
  - Kali Linux (ARM/ARM64) from [official source](https://www.kali.org/get-kali/#kali-arm)
  - Parrot OS ARM version
  - Raspbian / Raspberry Pi OS
  - Other Debian-based ARM distributions
- Compatible SPI TFT LCD Display (MHS35, LCD35, LCD7B, LCD24, etc.)
- Internet connection for dependency installation

---

## 🎯 Supported Operating Systems

| OS | Status | Notes |
|---|---|---|
| **Kali Linux ARM/ARM64** | ✅ Fully Supported | Tested on Kali Linux 2025.2 |
| **Parrot OS ARM** | ✅ Fully Supported | Auto-detected and configured |
| **Raspbian / Raspberry Pi OS** | ✅ Fully Supported | Original compatibility maintained |
| **Other Debian-based** | ⚠️ Experimental | Should work with most Debian derivatives |

---

## 📁 Repository Structure

| File / Folder | Purpose |
|---------------|---------|
| `*-show` scripts | 🔧 Installation scripts for different LCD models (e.g., MHS35-show, LCD35-show) |
| `os-detect.sh` | 🔍 **NEW**: Automatic OS and boot path detection |
| `lcd-show-common.sh` | 🛠️ **NEW**: Common functions for all scripts |
| `rotate.sh` | ↪️ Optional screen rotation logic |
| `LCD-hdmi` | 📺 Switch back to HDMI output |
| `system_backup.sh` | 🛡️ Backup current system files before installation |
| `system_restore.sh` | 🔄 Restore backed up system files |
| `usr/`, `boot/`, `etc/` | 📂 Drivers and config files |

---

## 🧪 Tested On

- **Kali Linux 2025.2 ARM64** on Raspberry Pi 5
- **Parrot OS ARM** on Raspberry Pi 4
- **Raspberry Pi OS** (formerly Raspbian) on various models
- Multiple LCD models: MHS35, LCD35, LCD7B, LCD24, LCD28, LCD32, and others

---

## ⚙️ Installation Instructions

### 🔹 1. Clone the Repository

```bash
sudo rm -rf LCD-show-kali
git clone https://github.com/at0m-b0mb/LCD-show-kali.git
chmod -R 775 LCD-show-kali
cd LCD-show-kali
```

---

### 🔹 2. Run the Installer for Your LCD Model

Choose the appropriate script for your LCD model:

#### For MHS35 Display:
```bash
sudo ./MHS35-show
```

#### For LCD35 Display:
```bash
sudo ./LCD35-show
```

#### For Other LCD Models:
```bash
sudo ./LCD7B-show    # For LCD7B 7" display
sudo ./LCD24-show    # For LCD24 2.4" display
sudo ./LCD28-show    # For LCD28 2.8" display
sudo ./LCD32-show    # For LCD32 3.2" display
# ... and many more
```

The script will:
- Automatically detect your OS (Kali Linux, Parrot OS, Raspbian, etc.)
- Detect the correct boot partition path (`/boot/` or `/boot/firmware/`)
- Install necessary dependencies
- Configure the LCD display
- Reboot the system

**Note**: The system will automatically reboot after installation.

---

### 🔹 3. Optional: Rotate the Display

After installation, you can rotate the display:

```bash
sudo ./rotate.sh [rotation]
```

Where `[rotation]` can be:
- `0` → Normal (no rotation)
- `90` → Portrait (90 degrees)
- `180` → Inverted (180 degrees)
- `270` → Portrait (270 degrees, other side)
- `360` → Horizontal flip (HDMI only)
- `450` → Vertical flip (HDMI only)

**Example:**
```bash
sudo ./rotate.sh 90
```

> ⚠️ **Note**: Rotation may not work perfectly on all Kali Linux and Parrot OS images due to X11/input driver differences. This is being actively improved.

---

## 🔄 To Switch Back to HDMI Output

If you want to disable the LCD and switch back to HDMI:

```bash
sudo ./LCD-hdmi
```

The system will reboot and use HDMI output.

---

## 🛠️ Dependencies Installed

The installation scripts automatically install the following packages (if not already present):

- `cmake` - For building fbcp (framebuffer copy tool)
- `git` - For cloning repositories
- `build-essential` - Compilation tools
- `xserver-xorg-input-evdev` - Touch input driver
- `libraspberrypi-dev` - Raspberry Pi libraries (on compatible systems)

Package installation is OS-aware and will use the appropriate package repositories for your system (Kali, Parrot, Raspbian, etc.).

---

## 💡 Troubleshooting

### 1. Display Stuck or Blank?

- Check your boot configuration file:
  - Kali Linux / Newer systems: `/boot/firmware/config.txt`
  - Raspbian / Older systems: `/boot/config.txt`
- Verify SPI is enabled in the config
- Ensure correct overlay is present: `dtoverlay=mhs35:rotate=90` (or your LCD model)
- Check that overlay files exist in the overlays directory

### 2. Touch Input Not Working?

- Confirm `/etc/X11/xorg.conf.d/99-calibration.conf` is in place
- Install/reinstall: `sudo apt-get install xserver-xorg-input-evdev`
- Try restarting fbcp: `sudo fbcp &`
- Check if touch device is detected: `ls /dev/input/`

### 3. Rotation Not Working?

- Try rotating using Xinput or `xrandr`
- Check if you're using X11 (not Wayland)
- Manual touch configuration may be needed
- Some rotations require specific calibration files

### 4. Package Installation Fails?

- Update package lists: `sudo apt-get update`
- Check your internet connection
- The scripts will fall back to local `.deb` packages if repository install fails
- For Kali/Parrot: Ensure your system is up-to-date with `sudo apt-get upgrade`

### 5. Boot Configuration Not Applied?

- Verify the correct boot path is being used
- Check system logs: `dmesg | grep -i lcd`
- Manually check the boot config file matches expected settings
- Some systems may require additional boot parameters

### 6. OS Not Detected Correctly?

- Run the OS detection manually: `bash os-detect.sh`
- Check `/etc/os-release` for OS information
- Report issues with OS detection on the GitHub issues page

---

## 🔍 How It Works

### OS Detection

The scripts now include an intelligent OS detection system (`os-detect.sh`) that:
1. Reads `/etc/os-release` to identify the operating system
2. Detects whether the system uses `/boot/` or `/boot/firmware/`
3. Automatically configures paths for overlay files
4. Selects appropriate package installation methods

This ensures compatibility across:
- **Kali Linux** (ID: kali)
- **Parrot OS** (ID: parrot)
- **Raspbian** (ID: raspbian)
- **Other Debian-based systems** (ID: debian)

### Boot Path Detection

Modern Raspberry Pi systems (including Kali Linux) use `/boot/firmware/` for boot configuration, while older Raspbian systems use `/boot/`. The scripts automatically detect and use the correct path.

---

## 🤝 Contributing

Contributions are welcome! If you:
- Test on a new OS or Raspberry Pi model
- Fix a bug or improve compatibility
- Add support for a new LCD model

Please open a Pull Request or Issue on GitHub.

---

## ❤️ Credits

- Based on the original driver from [GoodTFT](https://github.com/goodtft/LCD-show)
- Adapted for multi-OS support by [@at0m-b0mb](https://github.com/at0m-b0mb)
- Thanks to the Kali Linux and Parrot OS communities for testing

---

## 📜 License

MIT License — Free to use, modify, and distribute.

---

## 🙋‍♂️ Need Help?

- Open an [Issue](https://github.com/at0m-b0mb/LCD-show-kali/issues) on GitHub
- Contact [@at0m-b0mb](https://github.com/at0m-b0mb)
- Check the [Troubleshooting](#-troubleshooting) section above

---

## 📝 Changelog

### Latest Update
- ✅ Added support for Kali Linux ARM/ARM64
- ✅ Added support for Parrot OS ARM
- ✅ Automatic OS detection system
- ✅ Dynamic boot path detection (`/boot/` vs `/boot/firmware/`)
- ✅ OS-agnostic package installation
- ✅ Maintained backward compatibility with Raspbian
- ✅ Updated all LCD show scripts for multi-OS support
- ✅ Improved error handling and user feedback
