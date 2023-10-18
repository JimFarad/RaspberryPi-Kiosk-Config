**Repository Structure:**

```
/
├── README.md
├── update_kiosk.sh
├── .gitignore
└── .config/
    └── autostart/
        └── x11vnc.desktop
```

# Raspberry Pi Kiosk Mode Configuration

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
# Insert the script content here
```

Edit the `~/.bashrc` file:

```bash
nano ~/.bashrc
```

Add an alias for running the kiosk script:

```plaintext
# Alias to configure and run the Chromium kiosk mode
alias kiosk='sudo /home/linuxadmin/update_kiosk.sh'
```

Source the updated `~/.bashrc`:

```bash
source ~/.bashrc
```

## Reboot

You're now ready to reboot your Raspberry Pi. Before that, you can display a message to the user if desired.

```bash
sudo reboot
```

That's it! Your Raspberry Pi should now be configured in kiosk mode.
