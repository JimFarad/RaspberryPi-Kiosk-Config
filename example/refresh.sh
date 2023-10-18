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
