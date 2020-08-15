#!/bin/bash

echo "MUST BE RUN ON A MACHINE IN LOCAL NETWORK"

# Install Easy-RSA
sudo apt update
sudo apt install easy-rsa -y

# Public Key Infrastructure
mkdir $HOME/easy-rsa
ln -s /usr/share/easy-rsa/* $HOME/easy-rsa/
chmod 700 $HOME/easy-rsa

# Initialize PKI
cd $HOME/easy-rsa
./easyrsa init-pki

# Create CA
cd $HOME/easy-rsa
{
echo 'set_var EASYRSA_REQ_COUNTRY    "US"'
echo 'set_var EASYRSA_REQ_PROVINCE   "NewYork"'
echo 'set_var EASYRSA_REQ_CITY       "New York City"'
echo 'set_var EASYRSA_REQ_ORG        "DigitalOcean"'
echo 'set_var EASYRSA_REQ_EMAIL      "admin@example.com"'
echo 'set_var EASYRSA_REQ_OU         "Community"'
echo 'set_var EASYRSA_ALGO           "ec"'
echo 'set_var EASYRSA_DIGEST         "sha512"'
} > vars

# Create root public and private key pair for CA
./easyrsa build-ca
#./easyrsa build-ca nopass

# ca.crt is public certificate for verifying device is part of web of trust
# ca.key is private key used to sign certificates. Must destroy if hackers access this.

# Copy cert to destination machine
#cat $HOME/easy-rsa/pki/ca.crt > /tmp/ca.crt

# UBUNTU
#sudo cp /tmp/ca.crt /usr/local/share/ca-certificates/
#sudo update-ca-certificates

# FEDORA
#sudo cp /tmp/ca.crt /etc/pki/ca-trust/source/anchors/
#sudo update-ca-trust
