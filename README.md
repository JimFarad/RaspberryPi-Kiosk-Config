**Repository Structure:**

```
/
├── README.md
├── README_GR.md
├── install.sh
└── example/
    ├── .bashrc
    ├── refresh.sh
    ├── timesyncd.conf
    ├── update_kiosk.sh
    └── x11vnc.desktop
```

# Raspberry Pi Kiosk Mode Configuration

**Disclaimer**: To ensure proper kiosk mode operation, it is recommended to disable screen blanking. To do this, follow these steps:

1. Run the following command:
   ```bash
   sudo raspi-config
   ```

2. Navigate to **'2. Display Options'**

3. Select **'D2. Screen Blanking.'**

4. Choose **'No'** to disable screen blanking.

5. **Finish** the configuration, and reboot your Raspberry Pi.

This repository provides a step-by-step guide to configure a Raspberry Pi in kiosk mode, allowing it to display a specific web page or application on startup. Kiosk mode is useful for applications like digital signage or public displays.


## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Time Configuration](#time-configuration)
3. [VNC Server Installation](#vnc-server-installation)
4. [Custom Desktop Image](#custom-desktop-image)
5. [User Creation](#user-creation)
6. [Kiosk Script](#kiosk-script)
7. [Additional Customization](#additional-customization)
8. [Reboot](#reboot)
8. [Usage](#usage)

## Initial Setup

Before setting up kiosk mode, ensure your Raspberry Pi is up to date:

```bash
sudo apt update
sudo apt upgrade -y
```

Remove unnecessary packages:

```bash
sudo apt purge wolfram-engine scratch scratch2 nuscratch sonic-pi idle3 -y
sudo apt purge smartsim java-common minecraft-pi libreoffice* -y
sudo apt clean
sudo apt autoremove -y
```

Install the Chromium browser:

```bash
sudo apt-get install chromium-browser
```

## Time Configuration

To configure time synchronization, follow these steps:

1. Check your current time settings:

```bash
timedatectl status
```

2. Edit the `timesyncd.conf` file:

```bash
sudo nano /etc/systemd/timesyncd.conf
```

Add the following NTP servers under `[Time]`:

```
NTP=ntp-0.isc.tuc.gr ntp-2.isc.tuc.gr
```

3. Restart the systemd timesync service:

```bash
sudo systemctl restart systemd-timesyncd.service
```

4. Verify the updated time settings:

```bash
timedatectl status
```

## VNC Server Installation

To install the VNC server, run the following commands:

```bash
sudo apt-get install x11vnc
x11vnc -storepasswd
```

Create an autostart configuration for x11vnc:

```bash
cd ~/.config/autostart
nano x11vnc.desktop
```

Add the following content:

```plaintext
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=X11VNC
Exec=x11vnc -forever -usepw -display :0 -ultrafilexfer
StartupNotify=false
Terminal=false
Hidden=false
```

## Custom Desktop Image

To set a custom desktop image:

```bash
cd ~
sudo wget https://users.isc.tuc.gr/~gfarantouris/pictures/branding/logo_TUC-edit.png
sudo cp logo_TUC-edit.png /usr/share/rpd-wallpaper/
sudo mv /usr/share/rpd-wallpaper/logo_TUC-edit.png /usr/share/rpd-wallpaper/logo_TUC.png
```

## User Creation

Create a new user for the kiosk mode:

```bash
sudo useradd -m kiosk
sudo passwd kiosk
```

## Kiosk Script

A script to configure Chromium for kiosk mode is provided. Run the following commands:

```bash
cd ~
nano update_kiosk.sh
```

Add the script content to `update_kiosk.sh`:

```bash
#!/bin/bash

#
# Note: This script is used to configure Chromium for kiosk mode.
# It deletes the existing @chromium-browser --kiosk line from
# /etc/xdg/lxsession/LXDE-pi/autostart, inserts the provided website URL,
# and prompts the user for a reboot.
#
# Usage: Type 'kiosk' in the terminal to run this script.
#
# --- METADATA: ---
# Author : Farantouris Dimitris (gfarantouris)
#
# Date: October 2023
#


# Check if the script is being run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Ask the user for the website URL
read -p "Enter the URL for Chromium kiosk mode: " website

# Update the autostart file
sed -i '/@chromium-browser --kiosk/d' /etc/xdg/lxsession/LXDE-pi/autostart
echo "@chromium-browser --kiosk $website" >> /etc/xdg/lxsession/LXDE-pi/autostart

# Notify the user to reboot
echo "Changes have been made to the autostart file."
read -p "You should reboot now. Type 'yes' to reboot or 'no' to skip: " choice

if [ "$choice" = "yes" ]; then
  sudo reboot
else
  echo "You can manually reboot later."
fi
```

Edit the `~/.bashrc` file:

```bash
nano ~/.bashrc
```

Add an alias for running the kiosk script:

```plaintext
alias kiosk='sudo /home/linuxadmin/update_kiosk.sh'
```

Source the updated `~/.bashrc`:

```bash
source ~/.bashrc
```

## Reboot

You're now ready to reboot your Raspberry Pi.

```bash
sudo reboot
```

That's it! Your Raspberry Pi should now be configured in kiosk mode.

## Usage

To configure your Raspberry Pi in kiosk mode, follow these steps:

1. Open a terminal window on your Raspberry Pi.

2. Run the following command to start the configuration process:

```bash
kiosk
```

3. The script will guide you through the setup process. Follow the on-screen instructions to complete the configuration.

4. Once the configuration is done, you will be prompted to reboot your Raspberry Pi. Type "yes" to reboot immediately.
