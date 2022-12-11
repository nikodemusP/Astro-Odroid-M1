#/bin/bash
# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------
echo "Update System ..."
#
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade
#
DEBIAN_FRONTEND=noninteractive apt-get -y purge gimp \
                                                libreoffice* \
                                                thunderbird \
                                                transmission \
                                                transmission-common \
                                                transmission-remote-gtk \
                                                hexchat-common \
                                                hexchat \
                                                pidgin-data \
                                                pidgin \
                                                filezilla-common \
                                                filezilla \
                                                putty-tools \
                                                putty
#
DEBIAN_FRONTEND=noninteractive apt-get -y install avahi-daemon \
                                                  linux-headers-edge-rk3568-odroid \
                                                  armbian-firmware-full
#
echo "Install Base-Software..."
#
DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common \
                                                  git \
                                                  cmake \
                                                  tightvncserver \
                                                  net-tools \
                                                  novnc \
                                                  nginx \
                                                  menulibre \
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
#
DEBIAN_FRONTEND=noninteractive apt-get -y autoremove
DEBIAN_FRONTEND=noninteractive apt-get clean
# ---------------------------------------------------------------------------
# Astro-Software
# ---------------------------------------------------------------------------
echo "Setup Astro-Software..."
DEBIAN_FRONTEND=noninteractive apt-add-repository -y ppa:mutlaqja/ppa
DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:pch/phd2
#
DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B8B57C1AA716FC2
sh -c "echo deb http://www.ap-i.net/apt unstable main > /etc/apt/sources.list.d/skychart.list"
cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/
#
echo "Install Astro-Software..."
DEBIAN_FRONTEND=noninteractive apt-get install -y indi-full 
DEBIAN_FRONTEND=noninteractive apt-get install -y kstars-bleeding
DEBIAN_FRONTEND=noninteractive apt-get install -y ccdciel
DEBIAN_FRONTEND=noninteractive apt-get install -y gpsd
DEBIAN_FRONTEND=noninteractive apt-get install -y gpsd-clients
DEBIAN_FRONTEND=noninteractive apt-get install -y phd2
DEBIAN_FRONTEND=noninteractive apt-get install -y astrometry.net
# -------------------------------------------------------------------------
# Virtual GPS
# -------------------------------------------------------------------------
echo "Setup GPS..."
cd tmp
git clone https://github.com/rkaczorek/virtualgps.git virtualgps
cd virtualgps
pip3 install gps3
cmake .
cmake --install .
cd ..
rm -rf virtualgps
#
systemctl daemon-reload
sudo systemctl enable virtualgps.service
sudo systemctl start virtualgps.service
sudo systemctl enable gpsd.service
sudo systemctl start gpsd.service
# -------------------------------------------------------------------------
# VNC do not start the GUI any more
# -------------------------------------------------------------------------
echo "Setup VNC..."
systemctl set-default multi-user.target
cp etc/polkit-1/localauthority/50-local.d/* /etc/polkit-1/localauthority/50-local.d/
cp etc/systemd/system/vncserver@.service /etc/systemd/system/
cp .vnc/xstartup /home/astrodroid/.vnc/
#
systemctl daemon-reload
systemctl enable vncserver@1.service
systemctl start vncserver@1.service
# -------------------------------------------------------------------------
# NO VNC
# -------------------------------------------------------------------------
echo "Setup NoVNC..."
sudo rm -rf /var/www/*
sudo mv var/www/*  /var/www/
sudo mkdir /var/log/indiweb
chown astrodroid.astrodroid /var/log/indiweb
find /var/www/ -type f -exec chmod 555 {} \;
#
cp etc/systemd/system/gpspanel.service       /etc/systemd/system
cp etc/systemd/system/indiwebmanager.service /etc/systemd/system
cp etc/systemd/system/astropanel.service     /etc/systemd/system
cp etc/systemd/system/novnc.service          /etc/systemd/system
systemctl daemon-reload
#
systemctl enable gpspanel.service
systemctl start gpspanel.service
#
systemctl enable indiwebmanager.service
systemctl start indiwebmanager.service
#
systemctl enable astropanel.service
systemctl start astropanel.service
#
systemctl enable novnc.service
systemctl start novnc.service
# -----------------------------------------------------------------------
# Nginx
# -----------------------------------------------------------------------
echo "Setup Nginx..."
sudo cp etc/nginx/sites-available/astrodroid /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/astrodroid  /etc/nginx/sites-enabled/astrodroid
sudo rm /etc/nginx/sites-enabled/default
openssl req -x509 -nodes -newkey rsa:2048 -keyout novnc.pem -out novnc.pem -days 3650 -subj '/CN=Astrodroid/C=SK'
#
#
#
echo "* Please setup login-pwd" 
echo ""
echo "tightvncpasswd"
echo ""
echo "* reboot the system"
echo "sudo reboot"
