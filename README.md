# AstroPC

Setup of a Astro-Intel-Nuc based on the idea of Astroberry (www.astroberry.io)

## Installation

For the base linux installation I used the Linux Mint 21 Cinnamon Edition (Ubuntu 22.04 LTS).

Hostname: astropc
User: astropc

### Update the System

```
sudo apt-get update
sudo apt-get upgrade
````

### Add Repository-Keys

```
# Key for CCDciel
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B8B57C1AA716FC2
sudo sh -c "echo deb http://www.ap-i.net/apt unstable main > /etc/apt/sources.list.d/skychart.list"

# Key for Indi
sudo apt-add-repository ppa:mutlaqja/ppa

# Key for phd2
sudo add-apt-repository ppa:pch/phd2
```

Please keep in mind with Debian 11 the apt-key handling has to be changed. If the add-apt-repository
could not handle the new keys, you have to adapt the source-files and gpg-keys

```
# copy the key file
sudo cp /etc/apt/trusted.gpg /usr/share/keyrings/ubuntu_ppa.gpg
```

Change /etc/apt/sources.list.d/pch-phd2-jammy.list
```
deb [signed-by=/usr/share/keyrings/ubuntu_ppa.gpg] http://ppa.launchpad.net/pch/phd2/ubuntu jammy main
# deb-src http://ppa.launchpad.net/pch/phd2/ubuntu jammy main
```

Change /etc/apt/sources.list.d/mutlaqja-ppa-jammy.list
```
deb [signed-by=/usr/share/keyrings/ubuntu_ppa.gpg] http://ppa.launchpad.net/mutlaqja/ppa/ubuntu jammy main
# deb-src http://ppa.launchpad.net/mutlaqja/ppa/ubuntu jammy main
```

### Install all packages

```
# base packages
sudo apt install -y tigervnc-standalone-server \
               tigervnc-common \
               tigervnc-xorg-extension \
               net-tools \
               dnsmasq-base \
               novnc \
               nginx \
               openssh-server \
               libnginx-mod-http-auth-pam \
               libnginx-mod-http-dav-ext \
               libnginx-mod-http-echo \
               libnginx-mod-http-subs-filter \
               libnginx-mod-http-upstream-fair \
               python3 \
               python3-websockify \
               python3-gps \
               python3-flask \
               python3-flask-socketio \
               python3-gevent \
               python3-configargparse \
               python3-dateutil \
               python3-ephem \
               python3-pip \
               python3-gevent-websocket \
               python3-bottle \
               software-properties-common \
               git
               
# astronomy related ones
sudo apt install -y indi-full \
                    kstars-bleeding \
                    ccdciel \
                    gpsd \
                    gpsd-clients \
                    phd2 \
                    astrometry.net
# gps3                    
sudo pip3 install gps3
```

### Enable SSH Access

```
sudo systemctl enable ssh
sudo systemctl start ssh
```

### Setup Virtual GPS
```
git clone https://github.com/rkaczorek/virtualgps.git virtualgps
# -----------------------
# Virtual GPS
# -----------------------
cd virtualgps
sudo cp virtualgps.py       /usr/bin
sudo cp setlocation.sh      /usr/bin
sudo cp location.conf       /etc
sudo cp virtualgps.service  /etc/systemd/system
sudo cp setlocation.desktop /usr/share/applications
sudo systemctl enable virtualgps.service
sudo systemctl start virtualgps.service

cd ..
rm -rf virtualgps

# allow gpsd to access the socket
sudo sh -c "echo /dev/pts/* rw > /etc/apparmor.d/local/usr.sbin.gpsd"
sudo systemctl enable gpsd.service
sudo systemctl start gpsd.service
```

### Install VNC

```
# do not start the GUI any more
sudo systemctl set-default multi-user.target

# provide the tigervnc configuration
sudo cp etc/tigervnc/* /etc/tigervnc/
printf "astropc\nastropc\nn\n" | vncpasswd 

# enable some policy for vnc
etc/polkit-1/localauthority/50-local.d/

# start the tigervnc
sudo systemctl enable --now tigervncserver@:1.service
sudo systemctl start tigervncserver@:1.service
```

### NoVNC

```
# provide the www-directories
sudo rm -rf /var/www/*
sudo mv var/www/*  /var/www/
sudo systemctl enable novnc.service
sudo systemctl start novnc.service
sudo mkdir /var/log/indiweb

# secure the www-directory
sudo chown astropc.astropc /var/log/indiweb
find /var/www/ -type f -exec chmod 555 {} \;

# start the web-server
sudo ln -s /var/www/gpspanel/gpspanel.service /lib/systemd/system/gpspanel.service
sudo ln -s /var/www/indiwebmanager/indiwebmanager.service /lib/systemd/system/indiwebmanager.service
sudo ln -s /var/www/astropanel/astropanel.service /lib/systemd/system/astropanel.service
sudo ln -s /var/www/novnc/novnc.service /lib/systemd/system/novnc.service

sudo systemctl enable gpspanel.service
sudo systemctl start gpspanel.service

sudo systemctl enable indiwebmanager.service
sudo systemctl start indiwebmanager.service

sudo systemctl enable astropanel.service
sudo systemctl start astropanel.service

sudo systemctl enable novnc.service
sudo systemctl start novnc.service
```

### Configure Nginx

```
sudo cp etc/nginx/sites-available/astropc /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/astropc  /etc/nginx/sites-enabled/astropc
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx.service
```

### Create a Hotspot
```
sudo cp etc/NetworkManager/system-connections/Hotspot.nmconnection /etc/NetworkManager/system-connections/Hotspot.nmconnection
```

### Install and provide additional astronomy.net-files
```
wget -i astronomy.net
sudo dpkg -i *.deb
```

### Reboot the node
