#!/bin/bash

# CHECK SUDO PRIVELEGE
#sudo -l -U $USER
if sudo -v > /dev/null; then
	echo "ERROR: Must be a sudoer to continue"
	exit
fi

# INSTALL NETWORK TOOLS
if ! command -v ifconfig; then
	sudo yum install net-tools -y
fi

# NETWORK DETAILS
NIC=$(ip addr | awk '/state UP/ {print $2}' | sed 's/.$//')
MAC=$(ip link |  awk '/state UP/{getline; print}' | awk '{print $2}')
echo "Your machine name: $(hostname)"
echo "The active network interface: $NIC" 
echo "Your IP address: $(hostname -I)"
echo "Your MAC address: $MAC"

# INSTALL SSH
sudo dnf install openssh-server
sudo systemctl start sshd.service
sudo systemctl enable sshd.service

# INSTALL REMOTE DESKTOP
if ! command -v xrdp; then
	sudo yum install xrdp -y
fi

# VERIFY RDP SETUP
FILE="$HOME/.xsession"
OS_SESSION="lxsession -e LXDE -s Lubuntu"
RDPSTART="/etc/xrdp/startwm.sh" 
XSESSION="/etc/X11/Xsession"
if tail -1 $RDPSTART | grep -q $XSESSION; then
	if [ -f "$FILE" ]; then
		if grep -q "$OS_SESSION" "$FILE"; then
			:
		else
			echo "$OS_SESSION" >> "$FILE"
		fi
	else
		echo "$OS_SESSION" > "$FILE"
	fi
else
	#TODO: sed this if predictable
	read -r "You must edit $RDPSTART to include $XSESSION on the last line. Do you wish to edit now? (Y/n)" input
	case $input in
		[yY][eE][sS]|[yY])
		sudo nano $RDPSTART;;
		*)
		exit 1;;
	esac
fi
sudo service xrdp restart

# ENABLE WAKE ON LAN
if ! command -v ethtool; then
	sudo yum install ethtool
fi
# VERIFY IF WOL IS ENABLED
WOLSERVICE="/etc/systemd/system/wol.service"
if sudo ethtool "$NIC" | grep '[W]ake-on' | tail -1 | grep -q g; then
	echo "Magic Packet is enabled for WOL"
	echo "Verify if this is enabled for every boot"
	#TODO menu options for enabling WOL on boot
else
	# ENABLE WOL ON EVERY BOOT
    echo "[Unit]" | sudo tee -a $WOLSERVICE
    echo "Description=Configure Wake On LAN" | sudo tee -a $WOLSERVICE
    echo "" | sudo tee -a $WOLSERVICE
    echo "[Service]" | sudo tee -a $WOLSERVICE
    echo "Type=oneshot" | sudo tee -a $WOLSERVICE
    echo "ExecStart=/sbin/ethtool -s $NIC wol g" | sudo tee -a $WOLSERVICE
    echo "" | sudo tee -a $WOLSERVICE
    echo "[Install]" | sudo tee -a $WOLSERVICE
    echo "WantedBy=basic.target" | sudo tee -a $WOLSERVICE

	sudo systemctl daemon-reload
	sudo systemctl enable wol.service
	sudo systemctl start wol.service
fi
#TODO report MAC address to Magic Packet device (e.g. rasperry pi)
