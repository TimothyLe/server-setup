#!/bin/bash

# Web Services for Devices is a Microsoft API to enable programming connections to web service enabled devices

if systemctl list-units --full -all | grep -q wsdd; then
	sudo systemctl restart wsdd.service
	exit 1
fi

# Download the wsdd service
cd /tmp
wget https://github.com/christgau/wsdd/archive/master.zip
unzip master.zip
sudo mv wsdd-master/src/wsdd.py wsdd-master/src/wsdd
sudo cp wsdd-master/src/wsdd /usr/bin
sudo cp wsdd-master/etc/systemd/wsdd.service /etc/systemd/system

# Comment out Group and User
sudo sed -i 's/User/;User/' /etc/systemd/system/wsdd.service
sudo sed -i 's/Group/;Group/' /etc/systemd/system/wsdd.service

# Start the service
sudo systemctl daemon-reload
sudo systemctl start wsdd
sudo systemctl enable wsdd
#sudo systemctl status wsdd
