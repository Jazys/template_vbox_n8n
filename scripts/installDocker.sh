#!/bin/bash

[ `whoami` = root ] || exec sudo su -c $0

cat <<EOT >> /etc/issue
Self Hosted Low Code Tool Box (SHLCTB)
IP \4
EOT
cat <<EOT >> /etc/profile.d/docker-external-ip.sh
export EXTERNAL_IP=$(hostname -I | awk '{print $1}')
EOT
chmod +x /etc/profile.d/docker-external-ip.sh
apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'
apt update
apt install docker-ce -y
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
apt install npm -y
apt install screen -y
