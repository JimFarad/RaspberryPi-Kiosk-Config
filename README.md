# Raspberry Pi Kiosk Mode Configuration

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

* * *

**Hardware Used**: *Raspberry Pi Model X (e.g., Raspberry Pi 4)*

**Raspbian Version**: *Raspbian X (e.g., Raspbian Buster)*

* * *

**Disclaimer**: To ensure proper kiosk mode operation, it is recommended to disable screen blanking. To do this, follow these steps:

1. Run the following command:

   ```bash
   sudo raspi-config
   ```

2. Navigate to **'2. Display Options'**

3. Select **'D2. Screen Blanking.'**

4. Choose **'No'** to disable screen blanking.

5. **'Finish'** the configuration, and reboot your Raspberry Pi.

This repository provides a step-by-step guide to configure a Raspberry Pi in kiosk mode, allowing it to display a specific web page or application on startup. Kiosk mode is useful for applications like digital signage or public displays.

* * *

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Time Configuration](#time-configuration)
3. [Custom Desktop Image](#custom-desktop-image)
4. [User Creation](#user-creation)
5. [Kiosk Configuration Script](#kiosk-configuration-script)
6. [VNC Server Installation](#vnc-server-installation)
7. [Creating the 'kiosk' Command](#creating-the-kiosk-command)
8. [Reboot](#reboot)
9. [Usage](#usage)


## Initial Setup

1. Before setting up kiosk mode, ensure your Raspberry Pi is up to date:

   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```

2. Remove unnecessary packages:

   ```bash
   sudo apt purge wolfram-engine scratch scratch2 nuscratch sonic-pi idle3 -y
   sudo apt purge smartsim java-common minecraft-pi libreoffice* -y
   sudo apt clean
   sudo apt autoremove -y
   ```

3. Install the Chromium browser:

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

3. Add the following NTP servers under `[Time]`:

   ```
   NTP=ntp-0.isc.tuc.gr ntp-2.isc.tuc.gr
   ```

4. Restart the systemd timesync service:

   ```bash
   sudo systemctl restart systemd-timesyncd.service
   ```

5. Verify the updated time settings:

   ```bash
   timedatectl status
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


## Kiosk Configuration Script

1. A script to configure Chromium for kiosk mode is provided. Run the following commands:

   ```bash
   nano ~/update_kiosk.sh
   ```

2. Add the script content to `update_kiosk.sh`:

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
   # Author: Farantouris Dimitris (gfarantouris)
   # Date: October 2023
   #
   
   # Check if the script is being run with sudo
   if [ "$EUID" -ne 0 ]; then
     echo "Please run this script with sudo."
     exit 1
   fi
   
   # Prompt the user for the website URL to use in kiosk mode
   read -p "Enter the URL for kiosk mode: " website
   
   # Update the autostart file
   sudo sed -i '/@chromium-browser --kiosk/d' /etc/xdg/lxsession/LXDE-pi/autostart
   echo "@chromium-browser --kiosk \$website" >> /etc/xdg/lxsession/LXDE-pi/autostart
   
   # Notify the user to reboot
   echo "Changes have been made to the autostart file."
   read -p "You should reboot now. Type 'yes' to reboot or 'no' to skip: " choice
   
   if [ "\$choice" = "yes" ]; then
     sudo reboot
   else
     echo "You can manually reboot later."
   fi
   ```

3. Next, we'll grant execute permissions to the script.

   ```bash
   sudo chmod +x ~/update_kiosk.sh
   ```

4. At times, the default mouse position might conflict with elements on a webpage. To reposition the mouse to the top left corner, you can make adjustments in the `autostart` file:

   ```bash
   sudo nano /etc/xdg/lxsession/LXDE-pi/autostart
   ```

5. Add the subsequent line to the end of the file:

   ```bash
   @xdotool mousemove 0 0
   ```

The following script is designed to automatically refresh a webpage by simulating the press of the F5 button every 5 minutes (300 seconds). This periodic refresh ensures that the kiosk content remains up to date, making it ideal for displaying dynamic web-based information.

6. The script is located at `~/.config/autostart/refresh.sh` so we have to create the `refresh.sh` file:

   ```bash
   sudo nano /home/kiosk/.config/autostart/refresh.sh
   ```

   ```bash
   #!/bin/bash
   
   # Kiosk Refresh Script
   # Author: Farantouris Dimitris (gfarantouris)
   # Date: October 2023

   while true; do
       # Simulate pressing the F5 key to refresh the page
       xdotool key F5
   
       # Sleep for 5 minutes (300 seconds)
       sleep 300
   done
   ```
   
   ```bash
   sudo chown kiosk:kiosk /home/kiosk/.config/autostart/refresh.sh
   ```


## VNC Server Installation

1. To install the VNC server, run the following commands:

   ```bash
   sudo apt-get install x11vnc
   x11vnc -storepasswd
   ```

2. Then create a VNC password for the "kiosk" user, ensuring that the VNC server is set up for their use also.

   ```bash
   sudo -u kiosk x11vnc -storepasswd
   ```

3. Create an autostart configuration for x11vnc:

   ```bash
   mkdir -p ~/.config/autostart
   nano ~/.config/autostart/x11vnc.desktop
   ```

4. Add the following content:

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

5. You have to switch to the 'kiosk' user to perform specific actions on their behalf. To do so, use the following commands:

   ```bash
   su kiosk
   ```

   ```bash
   mkdir -p ~/.config/autostart
   nano ~/.config/autostart/x11vnc.desktop
   ```

6. Add the following content:

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

7. After completing tasks as the 'kiosk' user, you can return to the admin user with the following command:

   ```bash
   exit
   ```

These commands facilitate temporary user switching, allowing you to perform actions as the 'kiosk' user and then easily return to the admin user.


## Creating the 'kiosk' Command

To enhance user convenience and efficiently update the kiosk webpage, you can create a 'kiosk' command. This command simplifies the process of configuring and running the kiosk script.

Follow these steps to create and use the 'kiosk' command:

1. Edit the `.bashrc` file for the current user:

   ```bash
   nano ~/.bashrc
   ```

2. Add an alias to streamline the execution of the kiosk script. Insert the following line into the `.bashrc` file:

   ```plaintext
   alias kiosk='sudo /home/linuxadmin/update_kiosk.sh'
   ```

**Ensure to replace 'linuxadmin' with your administrator username in the following instructions.**

3. Save the changes and exit the text editor.

4. To apply the updated `.bashrc` configuration, source it using the following command:

   ```bash
   source ~/.bashrc
   ```

With the 'kiosk' command in place, you can efficiently update the kiosk webpage by simply running 'kiosk' in the terminal. This streamlines the process and simplifies kiosk mode management.


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
