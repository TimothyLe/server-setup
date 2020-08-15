#!/bin/bash

if ! command -v getenforce; then
	sudo apt-get install policycoreutils selinux-utils selinux-basics
fi

# ACTIVATE SELINUX
sudo selinux-activate

# SET ENFORCING MODE
sudo selinux-config-enforcing

# REBOOT TO TRIGGER RELABELLING
sudo reboot

# CHECK STATUS
estatus

# CHECK ENFORCEMENT
getenforce
