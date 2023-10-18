#!/bin/bash

#
# Note: This script is used to configure a Raspberry Pi for kiosk mode. It guides you through the setup process,
# allows you to customize various options, and provides status updates.
#
# Usage: Run this script with sudo.
#
# --- METADATA: ---
# Author : Farantouris Dimitris (gfarantouris)
#
# Date: October 2023
#

# Disclaimer
echo "Disclaimer: To ensure proper kiosk mode operation, it is recommended to disable screen blanking. To do this, please follow these steps:"
echo "1. Exit this script."
echo "2. Run the following command:"
echo "   sudo raspi-config"
echo "3. Navigate to '2. Display Options'."
echo "4. Select 'D2. Screen Blanking' and choose 'No.'"
echo "5. Finish the configuration and reboot your Raspberry Pi."
read -p "Once screen blanking is disabled, restart this script and press Enter to continue."

# Check if the script is being run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Welcome message
echo "Welcome to the Raspberry Pi Kiosk Mode Configuration Script"
echo "This script will help you set up your Raspberry Pi in kiosk mode."

# Update system packages
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y
echo "System packages updated."

# Remove unnecessary packages
echo "Removing unnecessary packages..."
sudo apt purge wolfram-engine scratch scratch2 nuscratch sonic-pi idle3 -y
sudo apt purge smartsim java-common minecraft-pi libreoffice* -y
sudo apt clean
sudo apt autoremove -y
echo "Unnecessary packages removed."

# Install Chromium browser
echo "Installing Chromium browser..."
sudo apt-get install chromium-browser -y
echo "Chromium browser installed."

# Configure time synchronization
echo "Configuring time synchronization..."

# Prompt the user for NTP servers
read -p "Enter the NTP servers (e.g., ntp-0.isc.tuc.gr ntp-2.isc.tuc.gr): " ntp_servers

# Update timesyncd.conf with the provided NTP servers
sudo sed -i 's/^#NTP=.*/NTP='"$ntp_servers"'/' /etc/systemd/timesyncd.conf

# Restart the systemd timesync service
sudo systemctl restart systemd-timesyncd.service
echo "Time synchronization configured."

# Install VNC server
echo "Installing VNC server..."
sudo apt-get install x11vnc -y
x11vnc -storepasswd
echo "VNC server installed."

# Set a custom desktop image
echo "Setting a custom desktop image..."
cd ~
sudo wget https://users.isc.tuc.gr/~gfarantouris/pictures/branding/logo_TUC-edit.png
sudo cp logo_TUC-edit.png /usr/share/rpd-wallpaper/
sudo mv /usr/share/rpd-wallpaper/logo_TUC-edit.png /usr/share/rpd-wallpaper/logo_TUC.png
echo "Custom desktop image set."

# Create a user for kiosk mode
echo "Creating a user for kiosk mode..."
read -p "Enter a password for the 'kiosk' user: " kiosk_password
sudo useradd -m kiosk
echo "kiosk:$kiosk_password" | sudo chpasswd
echo "User 'kiosk' created."

# Create the kiosk configuration script
echo "Creating the kiosk configuration script..."
cat <<EOF > /home/$SUDO_USER/update_kiosk.sh
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

# Prompt the user for the website URL
read -p "Enter the URL for kiosk mode: " website

# Update the autostart file
sudo sed -i '/@chromium-browser --kiosk/d' /etc/xdg/lxsession/LXDE-pi/autostart
echo "@chromium-browser --kiosk --kiosk-printing \$website" >> /etc/xdg/lxsession/LXDE-pi/autostart

# Notify the user to reboot
echo "Changes have been made to the autostart file."
read -p "You should reboot now. Type 'yes' to reboot or 'no' to skip: " choice

if [ "\$choice" = "yes" ]; then
  sudo reboot
else
  echo "You can manually reboot later."
fi
EOF

# Make the script executable
sudo chmod +x /home/$SUDO_USER/update_kiosk.sh
sudo chown linuxadmin:linuxadmin update_kiosk.sh

# Add an alias to .bashrc
echo "Adding an alias to .bashrc..."
echo "alias kiosk='sudo /home/$SUDO_USER/update_kiosk.sh'" >> /home/$SUDO_USER/.bashrc
source /home/$SUDO_USER/.bashrc
echo "Alias added to .bashrc."

# Final steps
echo "Configuration completed. You can now run 'kiosk' to configure the Chromium kiosk mode."
echo "Please reboot your Raspberry Pi for the changes to take effect."

# Prompt the user to reboot
read -p "Do you want to reboot now? (yes/no): " reboot_choice
if [ "$reboot_choice" = "yes" ]; then
  sudo reboot
else
  echo "You can manually reboot later to activate kiosk mode."
fi
