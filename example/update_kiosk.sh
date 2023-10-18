# ~/update_kiosk.sh

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
