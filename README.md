# AstroPC

Setup of a Odriod M1 based on the idea of Astroberry (www.astroberry.io)

## Installation

For the base linux installation I used the XUbuntu-Desktop (Ubuntu 22.04 LTS).

Hostname: astrodroid
User: astrodroid

### Update the System

```
sudo apt-get update
sudo apt-get upgrade
```

### Enable SSH Access (if not exists)

```
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

### Base-Tools

```
sudo apt install -y software-properties-common git
```


### Add Repository-Keys

```
# Key for CCDciel
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B8B57C1AA716FC2
sudo sh -c "echo deb http://www.ap-i.net/apt unstable main > /etc/apt/sources.list.d/skychart.list"
sudo cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/

# Key for Indi
sudo apt-add-repository ppa:mutlaqja/ppa

# Key for phd2
sudo add-apt-repository ppa:pch/phd2
```


### Install all packages

```
# base packages
sudo apt-get update

sudo apt install -y tigervnc-standalone-server \
               tigervnc-common \
               tigervnc-xorg-extension \
               net-tools \
               dnsmasq-base \
               novnc \
               nginx \
               xrdp \
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
               python3-bottle
```

```          
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

### Disable the automatic boot into the gui

```
# do not start the GUI any more
sudo systemctl set-default multi-user.target
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
printf "astrodroid\nastrodroid\nn\n" | vncpasswd

# enable some policy for vnc
sudo cp etc/polkit-1/localauthority/50-local.d/* /etc/polkit-1/localauthority/50-local.d/

# start the tigervnc
sudo systemctl enable --now tigervncserver@:2.service
sudo systemctl start tigervncserver@:2.service
```

### NoVNC, indiweb and other web-tools

```
# provide the www-directories
sudo rm -rf /var/www/*
sudo mv var/www/*  /var/www/
sudo mkdir /var/log/indiweb

# secure the www-directory
sudo chown odroid.odroid /var/log/indiweb
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
sudo cp etc/nginx/sites-available/astrodroid /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/astrodroid  /etc/nginx/sites-enabled/astrodroid
sudo rm /etc/nginx/sites-enabled/default
```

### Create a Hotspot
```
sudo cp etc/NetworkManager/system-connections/Hotspot.nmconnection /etc/NetworkManager/system-connections/AstrOdroid-Hotspot.nmconnection
```

### Install and provide additional astronomy.net-files
```
wget -i astronomy.net
sudo dpkg -i *.deb
```

### Reboot the node

