#!/bin/bash

[ `whoami` = root ] || exec sudo su -c $0

cat <<EOT >> /etc/issue
Self Hosted Low Code Tool Box (SHLCTB)
IP \4
EOT

#apt install screen -y
#curl -sL https://deb.nodesource.com/setup_12.x | sudo bash 
#apt install pkg-config 
#apt-get install -y nodejs 
#apt-get install build-essential -y

