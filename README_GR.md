**Δομή του Αποθετηρίου:**

```
/
├── README.md
├── update_kiosk.sh
├── .gitignore
└── .config/
    └── autostart/
        └── x11vnc.desktop
```

# Ρύθμιση Λειτουργίας Κιόσκι Raspberry Pi

Αυτό το αποθετήριο παρέχει έναν οδηγό βήμα προς βήμα για τη ρύθμιση ενός Raspberry Pi σε λειτουργία κιόσκι (kiosk mode), επιτρέποντάς του να εμφανίζει μια συγκεκριμένη ιστοσελίδα ή εφαρμογή κατά την εκκίνηση. Η λειτουργία κιόσκι είναι χρήσιμη για εφαρμογές όπως ψηφιακή σήμανση ή δημόσιες οθόνες ενημέρωσης.

## Πίνακας Περιεχομένων

1. [Αρχική Ρύθμιση](#αρχική-ρύθμιση)
2. [Ρύθμιση Χρόνου](#ρύθμιση-χρόνου)
3. [Εγκατάσταση Εξυπηρετητή VNC](#εγκατάσταση-εξυπηρετητή-vnc)
4. [Προσαρμοσμένη Εικόνα Επιφάνειας](#προσαρμοσμένη-εικόνα-επιφάνειας)
5. [Δημιουργία Χρήστη](#δημιουργία-χρήστη)
6. [Σενάριο Κιόσκι](#σενάριο-κιόσκι)
7. [Πρόσθετες Προσαρμογές](#πρόσθετες-προσαρμογές)
8. [Επανεκκίνηση](#επανεκκίνηση)

## Αρχική Ρύθμιση

Πριν ρυθμίσετε τη λειτουργία κιόσκι, βεβαιωθείτε ότι ο Raspberry Pi σας είναι ενημερωμένος:

```bash
sudo apt update
sudo apt upgrade -y
```

Καταργήστε τα περιττά πακέτα:

```bash
sudo apt purge wolfram-engine scratch scratch2 nuscratch sonic-pi idle3 -y
sudo apt purge smartsim java-common minecraft-pi libreoffice* -y
sudo apt clean
sudo apt autoremove -y
```

Εγκαταστήστε τον περιηγητή Chromium:

```bash
sudo apt-get install chromium-browser
```

## Ρύθμιση Χρόνου

Για να διαμορφώσετε τον συγχρονισμό του χρόνου, ακολουθήστε αυτά τα βήματα:

1. Ελέγξτε τις τρέχουσες ρυθμίσεις του χρόνου:

```bash
timedatectl status
```

2. Επεξεργαστείτε το αρχείο `timesyncd.conf`:

```bash
sudo nano /etc/systemd/timesyncd.conf
```

Προσθέστε τους παρακάτω εξυπηρετητές NTP κάτω από το `[Time]`:

```
NTP=ntp-0.isc.tuc.gr ntp-2.isc.tuc.gr
```

3. Επανεκκινήστε την υπηρεσία συγχρονισμού του systemd:

```bash
sudo systemctl restart systemd-timesyncd.service
```

4. Βεβαιωθείτε για τις ενημερωμένες ρυθμίσεις του χρόνου:

```bash
timedatectl status
```

## Εγκατάσταση Εξυπηρετητή VNC

Για να εγκαταστήσετε τον εξυπηρετητή VNC, εκτελέστε τις ακόλουθες εντολές:

```bash
sudo apt-get install x11vnc
x11vnc -storepasswd
```

Δημιουργήστε μια ρύθμιση εκκίνησης για τον x11vnc:

```bash
cd ~/.config/autostart
nano x11vnc.desktop
```

Προσθέστε τον ακόλου

θο περιεχόμενο:

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

## Προσαρμοσμένη Εικόνα Επιφάνειας

Για να ορίσετε μια προσαρμοσμένη εικόνα επιφάνειας:

```bash
cd ~
sudo wget https://users.isc.tuc.gr/~gfarantouris/pictures/branding/logo_TUC-edit.png
sudo cp logo_TUC-edit.png /usr/share/rpd-wallpaper/
sudo mv /usr/share/rpd-wallpaper/logo_TUC-edit.png /usr/share/rpd-wallpaper/logo_TUC.png
```

## Δημιουργία Χρήστη

Δημιουργήστε ένα νέο χρήστη για τη λειτουργία κιόσκι:

```bash
sudo useradd -m kiosk
sudo passwd kiosk
```

## Σενάριο Κιόσκι

Παρέχεται ένα σενάριο για τη ρύθμιση του Chromium σε λειτουργία κιόσκι. Εκτελέστε τις ακόλουθες εντολές:

```bash
cd ~
nano update_kiosk.sh
```

Προσθέστε το περιεχόμενο του σεναρίου στο `update_kiosk.sh`:

```bash
# Εισάγετε το περιεχόμενο του σεναρίου εδώ
```

Επεξεργαστείτε το αρχείο `~/.bashrc`:

```bash
nano ~/.bashrc
```

Προσθέστε ένα ψευδώνυμο για την εκτέλεση του σεναρίου κιόσκι:

```plaintext
# Ψευδώνυμος για τη ρύθμιση και εκτέλεση της λειτουργίας κιόσκι του Chromium
alias kiosk='sudo /home/linuxadmin/update_kiosk.sh'
```

Πηγαίνετε στο τερματικό και εκτελέστε:

```bash
source ~/.bashrc
```

## Επανεκκίνηση

Είστε πλέον έτοιμοι για την επανεκκίνηση του Raspberry Pi σας.

```bash
sudo reboot
```

Αυτό είναι! Ο Raspberry Pi σας πρέπει τώρα να είναι ρυθμισμένος σε λειτουργία κιόσκι.

## Χρήση

Για να ρυθμίσετε το Raspberry Pi σας σε λειτουργία κιόσκι, ακολουθήστε αυτά τα βήματα:

1. Ανοίξτε ένα παράθυρο τερματικού στο Raspberry Pi σας.

2. Εκτελέστε την ακόλουθη εντολή για να ξεκινήσετε τη διαδικασία ρύθμισης:

```bash
kiosk
```

3. Το σενάριο θα σας καθοδηγήσει μέσα από τη διαδικασία ρύθμισης. Ακολουθήστε τις οδηγίες που εμφανίζονται στην οθόνη για να ολοκληρώσετε τη ρύθμιση.

4. Μόλις ολοκληρωθεί η ρύθμιση, θα σας ζητηθεί να επανεκκινήσετε το Raspberry Pi σας. Πληκτρολογήστε "yes" για να επανεκκινήσετε αμέσως.
