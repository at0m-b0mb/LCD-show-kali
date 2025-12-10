# MHS35 3.5" TFT LCD Driver for Raspberry Pi 5 (Kali Linux)

This repository contains an installation script for enabling the **MHS35 3.5" SPI TFT touchscreen display** on the **Raspberry Pi 5** running **Kali Linux ARM64**.

> 🛠️ Forked from [GoodTFT's LCD-show](https://github.com/goodtft/LCD-show)  
> 💻 Customized by [@at0m-b0mb](https://github.com/at0m-b0mb) for full compatibility with Kali Linux and Raspberry Pi 5  
> 📦 Includes framebuffer mirroring (`fbcp`), calibration, and optional rotation support

---

## 🚀 Features

- ✅ Tested on **Kali Linux ARM64** (2025)
- ✅ Fully supports **Raspberry Pi 5** (SPI + HDMI)
- ✅ Installs required drivers and device overlays
- ✅ Enables touch and display output via SPI
- ✅ Optional framebuffer mirroring via `fbcp`
- ⚠️ Rotation is **not fully functional yet** on some setups — work in progress

---

## 📦 Requirements

- Raspberry Pi 5
- Kali Linux (ARM64) from [official source](https://www.kali.org/get-kali/#kali-arm)
- MHS35 3.5” SPI TFT LCD Display
- Internet connection for dependency installation

---

## 📁 Repository Structure

| File / Folder | Purpose |
|---------------|---------|
| `MHS35-PI5-show.sh` | 🔧 Main installation script |
| `rotate.sh` | ↪️ Optional screen rotation logic |
| `usr/`, `boot/`, `etc/` | 📂 Drivers and config files (from GoodTFT repo) |
| `system_backup.sh` | 🛡️ Optional: Backup current system files |
| `system_config.sh` | 📊 Detects OS version (Debian-based check) |

---

## 🧪 Tested On

- Raspberry Pi 5 (8GB model)
- Kali Linux 2025.2 ARM64 (XFCE)
- MHS35 SPI TFT LCD from LCDWiki
- HDMI to SPI framebuffer mirroring with `fbcp`

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

### 🔹 2. Run the Installer

```bash
sudo ./MHS35-PI5-show.sh
```

You can replace `90` with:
- `0` → Normal (no rotation)
- `90` → Portrait
- `180` → Inverted
- `270` → Portrait (other side)

> ⚠️ Note: Rotation may not work on all Kali Linux images due to X11/input driver quirks. Actively being improved.

---

## 🔄 To Switch Back to HDMI Output (Disable LCD)

```bash
sudo ./LCD-hdmi
```

---

## 🛠️ Dependencies Installed

The script automatically installs:

- `cmake`
- `git`
- `build-essential`
- `xserver-xorg-input-evdev`
- `libraspberrypi-dev`

---

## 💡 Troubleshooting

### 1. Only Terminal Login Shows (No Desktop GUI)?
**Solution:** The installer now automatically fixes this by:
- Setting systemd to boot into graphical mode (`graphical.target`)
- Enabling the display manager (LightDM/GDM3)

If you installed before this fix, run:
```bash
sudo systemctl set-default graphical.target
sudo systemctl enable lightdm.service  # or gdm3.service
sudo reboot
```

### 2. Display Stuck or Blank?
- Check `/boot/firmware/config.txt`
- Verify SPI is enabled
- Ensure correct overlay: `dtoverlay=mhs35:rotate=90`

### 3. Touch Input Not Working?
- Confirm `/etc/X11/xorg.conf.d/99-calibration.conf` is in place
- Install: `xserver-xorg-input-evdev`
- Try `fbcp` restart: `sudo fbcp &`

### 4. Rotation Not Working?
- Try rotating using Xinput or `xrandr`
- Check if you're using X11 (not Wayland)
- Manual touch config may be needed

---

## ❤️ Credits

- Based on the original driver from [GoodTFT](https://github.com/goodtft/LCD-show)
- Adapted for Kali Linux + Pi 5 by [@at0m-b0mb](https://github.com/at0m-b0mb)

---

## 📜 License

MIT License — Free to use, modify, and distribute.

---

## 🙋‍♂️ Need Help?

Open an [Issue](https://github.com/at0m-b0mb/LCD-show-kali/issues) or ping [@at0m-b0mb](https://github.com/at0m-b0mb)
