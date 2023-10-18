# Raspberry Pi Kiosk Mode Configuration

[![Read in English](https://img.shields.io/badge/Read%20in-English-brightgreen)](README.md)

**Repository Structure:**

```
/
├── README.md
├── README_GR.md
├── install.sh
└──/
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

**Disclaimer**: Για να διασφαλιστεί η σωστή λειτουργία της λειτουργίας περιπτέρου, συνιστάται η απενεργοποίηση του σβησίματος οθόνης. Για να το κάνετε αυτό, ακολουθήστε τα παρακάτω βήματα:

1. Εκτελέστε την ακόλουθη εντολή:

   ```bash
   sudo raspi-config
   ```

2. Πλοηγηθείτε στο **'2. Display Options'**

3. Επιλέξτε **'D2. Screen Blanking.'**

4. Επιλέξτε **'No'** για να απενεργοποιήσετε το σβήσιμο οθόνης.

5. **'Finish'** τη διαμόρφωση και επανεκκινήστε το Raspberry Pi.

Αυτό το αποθετήριο παρέχει έναν βήμα προς βήμα οδηγό για τη διαμόρφωση ενός Raspberry Pi σε λειτουργία περιπτέρου, επιτρέποντάς του να εμφανίζει μια συγκεκριμένη ιστοσελίδα ή εφαρμογή κατά την εκκίνηση. Η λειτουργία περιπτέρου είναι χρήσιμη για εφαρμογές όπως η ψηφιακή σήμανση ή οι δημόσιες οθόνες.

* * *

## Πίνακας περιεχομένων

1. [Αρχική ρύθμιση](#αρχική-ρύθμιση)
2. [Ρύθμιση ώρας](#ρύθμιση-ώρας)
3. [Προσαρμοσμένη εικόνα επιφάνειας εργασίας](#προσαρμοσμένη-εικόνα-επιφάνειας-εργασίας)
4. [Δημιουργία χρήστη](#δημιουργία-χρήστη)
5. [Script διαμόρφωσης περιπτέρου](#script-διαμόρφωσης-περιπτέρου)
6. [Εγκατάσταση σύνδεσης απομακρυσμένης επιφάνειας εργασίας (Remote Desktop Connection) με το VNC](#εγκατάσταση-σύνδεσης-απομακρυσμένης-επιφάνειας-εργασίας-remote-desktop-connection-με-το-vnc)
7. [Δημιουργία της εντολής 'kiosk'](#δημιουργία-της-εντολής-kiosk)
8. [Επανεκκίνηση](#επανεκκίνηση)
9. [Χρήση](#χρήση)


## Αρχική ρύθμιση

1. Πριν ρυθμίσετε τη λειτουργία περιπτέρου, βεβαιωθείτε ότι το Raspberry Pi σας είναι ενημερωμένο:

   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```

2. Αφαιρέστε τα περιττά πακέτα:

   ```bash
   sudo apt purge wolfram-engine scratch scratch2 nuscratch sonic-pi idle3 -y
   sudo apt purge smartsim java-common minecraft-pi libreoffice* -y
   sudo apt clean
   sudo apt autoremove -y
   ```

3. Εγκαταστήστε το πρόγραμμα περιήγησης Chromium:

   ```bash
   sudo apt-get install chromium-browser
   ```
   
## Ρύθμιση ώρας

Για να διαμορφώσετε το συγχρονισμό του χρόνου, ακολουθήστε τα παρακάτω βήματα:

1. Ελέγξτε τις τρέχουσες ρυθμίσεις ώρας:

   ```bash
   timedatectl status
   ```

2. Επεξεργαστείτε το αρχείο `timesyncd.conf`:

   ```bash
   sudo nano /etc/systemd/timesyncd.conf
   ```

3. Προσθέστε τους ακόλουθους διακομιστές NTP κάτω απο το `[Time]`:

   ```
   NTP=ntp-0.isc.tuc.gr ntp-2.isc.tuc.gr
   ```

4. Κάντε επανεκκίνηση της υπηρεσίας systemd timesync:

   ```bash
   sudo systemctl restart systemd-timesyncd.service
   ```

5. Επαληθεύστε τις ενημερωμένες ρυθμίσεις ώρας:

   ```bash
   timedatectl status
   ```

## Προσαρμοσμένη εικόνα επιφάνειας εργασίας

Για να ορίσετε μια προσαρμοσμένη εικόνα επιφάνειας εργασίας:

```bash
cd ~
sudo wget https://users.isc.tuc.gr/~gfarantouris/pictures/branding/logo_TUC-edit.png
sudo cp logo_TUC-edit.png /usr/share/rpd-wallpaper/
sudo mv /usr/share/rpd-wallpaper/logo_TUC-edit.png /usr/share/rpd-wallpaper/logo_TUC.png
```


## Δημιουργία χρήστη

Δημιουργήστε έναν νέο χρήστη για τη λειτουργία kiosk:

```bash
sudo useradd -m kiosk
sudo passwd kiosk
```


## Script διαμόρφωσης περιπτέρου

1. Παρέχεται ένα script για τη διαμόρφωση του Chromium για τη λειτουργία kiosk. Εκτελέστε τις ακόλουθες εντολές:

   ```bash
   nano ~/update_kiosk.sh
   ```

2. Προσθέστε το περιεχόμενο της δέσμης ενεργειών στο αρχείο `update_kiosk.sh`:

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

3. Στη συνέχεια, θα χορηγήσουμε δικαιώματα εκτέλεσης στο script.

   ```bash
   sudo chmod +x ~/update_kiosk.sh
   ```

4. Ορισμένες φορές, η προεπιλεγμένη θέση του ποντικιού μπορεί να έρχεται σε σύγκρουση με στοιχεία σε μια ιστοσελίδα. Για να επανατοποθετήσετε το ποντίκι στην επάνω αριστερή γωνία, μπορείτε να κάνετε προσαρμογές στο αρχείο `autostart`:

   ```bash
   sudo nano /etc/xdg/lxsession/LXDE-pi/autostart
   ```

5. Προσθέστε την επόμενη γραμμή στο τέλος του αρχείου:

   ```bash
   @xdotool mousemove 0 0
   ```

Το ακόλουθο script έχει σχεδιαστεί για την αυτόματη ανανέωση μιας ιστοσελίδας προσομοιώνοντας το πάτημα του πλήκτρου F5 κάθε 5 λεπτά (300 δευτερόλεπτα). Αυτή η περιοδική ανανέωση εξασφαλίζει ότι το περιεχόμενο του περιπτέρου παραμένει ενημερωμένο, καθιστώντας το ιδανικό για την προβολή δυναμικών πληροφοριών που βασίζονται στον ιστό.

6. Το script βρίσκεται στη διεύθυνση `~/.config/autostart/refresh.sh`, οπότε πρέπει να δημιουργήσουμε το αρχείο `refresh.sh`:

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


## Εγκατάσταση σύνδεσης απομακρυσμένης επιφάνειας εργασίας (Remote Desktop Connection) με το VNC

1. Για να εγκαταστήσετε το διακομιστή VNC, εκτελέστε τις ακόλουθες εντολές:

   ```bash
   sudo apt-get install x11vnc
   x11vnc -storepasswd
   ```

2. Στη συνέχεια, δημιουργήστε έναν κωδικό πρόσβασης VNC για τον χρήστη "kiosk", διασφαλίζοντας ότι ο διακομιστής VNC έχει ρυθμιστεί και για τη δική του χρήση.

   ```bash
   sudo -u kiosk x11vnc -storepasswd
   ```

3. Δημιουργήστε μια ρύθμιση αυτόματης εκκίνησης για το x11vnc:

   ```bash
   mkdir -p ~/.config/autostart
   nano ~/.config/autostart/x11vnc.desktop
   ```

4. Προσθέστε το ακόλουθο περιεχόμενο:

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

5. Πρέπει να μεταβείτε στον χρήστη του περιπτέρου για να εκτελέσετε συγκεκριμένες ενέργειες για λογαριασμό του. Για να το κάνετε αυτό, χρησιμοποιήστε τις ακόλουθες εντολές:

   ```bash
   su kiosk
   ```

   ```bash
   mkdir -p ~/.config/autostart
   nano ~/.config/autostart/x11vnc.desktop
   ```

6. Προσθέστε το ακόλουθο περιεχόμενο:

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

7. Αφού ολοκληρώσετε τις εργασίες ως χρήστης 'kiosk', μπορείτε να επιστρέψετε στον χρήστη admin με την ακόλουθη εντολή:

   ```bash
   exit
   ```

Αυτές οι εντολές διευκολύνουν την προσωρινή εναλλαγή χρηστών, επιτρέποντάς σας να εκτελείτε ενέργειες ως χρήστης 'kiosk' και στη συνέχεια να επιστρέφετε εύκολα στο χρήστη admin.

## Δημιουργία της εντολής 'kiosk'

Για να αυξήσετε την ευκολία του χρήστη και να ενημερώσετε αποτελεσματικά την ιστοσελίδα του περιπτέρου, μπορείτε να δημιουργήσετε μια εντολή 'kiosk'. Αυτή η εντολή απλοποιεί τη διαδικασία διαμόρφωσης και εκτέλεσης του σεναρίου kiosk.

Ακολουθήστε τα παρακάτω βήματα για να δημιουργήσετε και να χρησιμοποιήσετε την εντολή 'kiosk':

1. Επεξεργαστείτε το αρχείο `.bashrc` για τον τρέχοντα χρήστη:

   ```bash
   nano ~/.bashrc
   ```

2. Προσθέστε ένα ψευδώνυμο για τον εξορθολογισμό της εκτέλεσης του σεναρίου kiosk. Εισάγετε την ακόλουθη γραμμή στο αρχείο `.bashrc`:

   ```plaintext
   alias kiosk='sudo /home/linuxadmin/update_kiosk.sh'
   ```

**Φροντίστε να αντικαταστήσετε το "linuxadmin" με το όνομα χρήστη του διαχειριστή σας στις ακόλουθες οδηγίες.**

3. Αποθηκεύστε τις αλλαγές και βγείτε από τον επεξεργαστή κειμένου.

4. Για να εφαρμόσετε την ενημερωμένη διαμόρφωση `.bashrc`, πάρτε την πηγή χρησιμοποιώντας την ακόλουθη εντολή:

   ```bash
   source ~/.bashrc
   ```

Με την εντολή 'kiosk' στη θέση της, μπορείτε να ενημερώσετε αποτελεσματικά την ιστοσελίδα kiosk εκτελώντας απλά την εντολή 'kiosk' στο τερματικό. Αυτό βελτιώνει τη διαδικασία και απλοποιεί τη διαχείριση της λειτουργίας kiosk.

## Επανεκκίνηση

Τώρα είστε έτοιμοι να επανεκκινήσετε το Raspberry Pi.

```bash
sudo επανεκκίνηση
```

Αυτό ήταν! Το Raspberry Pi σας θα πρέπει τώρα να έχει ρυθμιστεί σε λειτουργία περιπτέρου.


## Χρήση

Για να ρυθμίσετε το Raspberry Pi σας σε λειτουργία περιπτέρου, ακολουθήστε τα παρακάτω βήματα:

1. Ανοίξτε ένα παράθυρο τερματικού στο Raspberry Pi σας.

2. Εκτελέστε την ακόλουθη εντολή για να ξεκινήσει η διαδικασία διαμόρφωσης:

   ```bash
   kiosk
   ```

3. Το script θα σας καθοδηγήσει στη διαδικασία ρύθμισης. Ακολουθήστε τις οδηγίες που εμφανίζονται στην οθόνη για να ολοκληρώσετε τη διαμόρφωση.

4. Μόλις ολοκληρωθεί η διαμόρφωση, θα σας ζητηθεί να επανεκκινήσετε το Raspberry Pi. Πληκτρολογήστε "yes" για να κάνετε αμέσως επανεκκίνηση.
