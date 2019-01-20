#!/bin/bash
# GET ALL USER INPUT
echo 'Wellcome to Parse Server and Dashboard on Ubuntu 18.04 install bash script';
sleep 2;
echo "Domain Name (eg. example.com)?"
read DOMAIN
cd ~
echo 'installing python-software-properties';
sleep 2;
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install -y build-essential git python-software-properties pwgen nginx

echo 'installing Node Js';
sleep 2;

sudo apt-get install -y nodejs
sudo apt-get install -y build-essential

echo 'installing Mongo DB';
sleep 2;

echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo service mongod start

echo "Setting up Cloudflare FULL SSL"
sleep 2;
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
cd /etc/nginx/
sudo mv nginx.conf nginx.conf.backup
sudo wget -O nginx.conf https://goo.gl/n8crcR
sudo mkdir /var/www/"$DOMAIN"
cd /var/www/"$DOMAIN"

echo 'Installing Parse Server Dashboard and PM2';
sleep 2;

npm install -g parse-server mongodb-runner parse-dashboard pm2@latest --no-optional --no-shrinkwrap
git clone https://github.com/ParsePlatform/parse-server-example.git
cd parse-server-example

echo
echo 'Downloading Parse Server Dashboard Configrtion Files';
sleep 2;

sudo curl https://raw.githubusercontent.com/bajpangosh/Install-Parse-Server-on-Ubuntu/master/parse-dashboard-config.json > parse-dashboard-config.json
sudo curl https://raw.githubusercontent.com/bajpangosh/Install-Parse-Server-on-Ubuntu/master/dashboard-running.json > dashboard-running.json
npm -g install
echo
echo 'Adding APP_ID and MASTER_KEY';
sleep 2;
APP_ID=`pwgen -s 24 1`
sudo sed -i "s/appId: process.env.APP_ID || .*/appId: process.env.APP_ID || '$APP_ID',/" /var/www/"$DOMAIN"/parse-server-example/index.js
MASTER_KEY=`pwgen -s 26 1`
sudo sed -i "s/masterKey: process.env.MASTER_KEY || .*/masterKey: process.env.MASTER_KEY || '$MASTER_KEY',/" /var/www/"$DOMAIN"/parse-server-example/index.js
echo 'Happy Ending';
echo
pm2 start index.js && pm2 startup
pm2 start dashboard-running.json && pm2 startup
pm2 status
echo "Here is your App Credentials"
echo "APP ID:   $APP_ID"
echo "MASTER KEY:   $MASTER_KEY"

echo "Installation & configuration succesfully finished.
Twitter: @TeamKloudboy
e-mail: support@kloudboy.com
Bye!"
