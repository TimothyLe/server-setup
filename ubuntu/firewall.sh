#!/bin/bash

if ! command -v firewall-cmd; then
	sudo apt-get install firewalld
fi

#firewall-cmd --add-service=samba --permanent
#firewall-cmd --reload
#getenforce
#setsebool -P samba_enable_home-dirs on
