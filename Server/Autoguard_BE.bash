#!/bin/bash
#Storyline: Waits for new files created by osTicket in /etc/incoming_config 
#and uses the contents to create a new entry in the wireguard config file
#then formats a new config file and sends it to the cleint

#Waits for a new file to be created
inotifywait -r -e create -m --format '%w%f' /etc/incoming_config | \
    while read f; do
    VAR=$f
    if [[ -f $VAR ]]; then
	#Stops the wireguard service
        sudo systemctl stop wg-quick@wg0

    	#Get the most recently used IP and mask from variable files
    	next_ip=$(tail /etc/scripts/vars/next_ip)
	address=$(cat /etc/scripts/vars/address)
	prefix=$(cat /etc/scripts/vars/prefix)

    	#Grabs the data sent from the client and puts into variables
    	config=$(tail $f)
    	pub_key=$(echo $config |cut -d '*' -f 1)
    	endpoint=$(echo $config |cut -d '*' -f 2)
	email=$(echo $config |cut -d '*' -f 3)
	hostname=$(echo $config |cut -d '*' -f 4)
	address=$(echo $address"."$next_ip$prefix)

    	# Formet the new peer line in /etc/wireguard/wg0.conf
    	printf '\n[Peer]\n' >> /etc/wireguard/wg0.conf
    	echo $pub_key >> /etc/wireguard/wg0.conf
    	echo "AllowedIPs = "$address >> /etc/wireguard/wg0.conf
    	echo $endpoint >> /etc/wireguard/wg0.conf

    	#Start wireguard up again
    	sudo systemctl start wg-quick@wg0

	#Moves the config file to parsed_config directory
    	mv $f /etc/scripts/parsed_config

	#Creates a new file to be sent back to the client
	touch /etc/scripts/outconf/$hostname.conf
	#Writes the specified config from int_vars to the new file
	cat /etc/scripts/vars/int_vars >> /etc/scripts/outconf/$hostname.conf
	#Writes the cleint private IP to new file
	( echo "Address = $address" ; echo "" ) >> /etc/scripts/outconf/$hostname.conf
	#Writes the specified config from peer_vars to the new file
	cat /etc/scripts/vars/peer_vars >> /etc/scripts/outconf/$hostname.conf
	#Emails the config file to client
	mail -s $hostname"-config" -a /etc/scripts/outconf/$hostname.conf $email <<< 'Config file generated successfully, please run Autoguard_Client2.ps1 and select the attached file when prompted.'
	#Moves the config file to outconf_old
	mv /etc/scripts/outconf/$hostname.conf /etc/scripts/outconf_old
	#Adds 1 to the value of the next_ip variable for the next iteration of the script
	the_ip="$(($next_ip + 1))"
	echo "$the_ip" > /etc/scripts/vars/next_ip
    elif [[ -d $VAR ]]; then
	#This clause prevents the script from running when a new directory is created in the osTicket outconfig directory
        echo "$f is a directory"
    fi
done
