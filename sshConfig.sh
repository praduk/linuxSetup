#!/bin/bash
#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

echo "CanonicalDomains local" >> /etc/ssh/ssh_config
echo "CanonicalizeHostname yes" >> /etc/ssh/ssh_config
echo "CanonicalizeMaxDots 0"  >> /etc/ssh/ssh_config

