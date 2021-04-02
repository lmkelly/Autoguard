#!/bin/bash

inotifywait -r -e create -m --format '%w%f' /etc/incoming_config | \
    while read f; do
    VAR=$f
    if [[ -f $VAR ]]; then
        sudo systemctl stop wg-quick@wg0

    	#Get the most recently used IP
    	next_ip=$(tail /etc/scripts/vars/next_ip)
	address=$(cat /etc/scripts/vars/address)
	prefix=$(cat /etc/scripts/vars/prefix)

    	#Splice config file
    	config=$(tail $f)
    	pub_key=$(echo $config |cut -d '*' -f 1)
    	endpoint=$(echo $config |cut -d '*' -f 2)
	email=$(echo $config |cut -d '*' -f 3)
	hostname=$(echo $config |cut -d '*' -f 4)
	address=$(echo $address"."$next_ip$prefix)

    	# Formet the new peer line
    	printf '\n[Peer]\n' >> /etc/wireguard/wg0.conf
    	echo $pub_key >> /etc/wireguard/wg0.conf
    	echo "AllowedIPs = "$address >> /etc/wireguard/wg0.conf
    	echo $endpoint >> /etc/wireguard/wg0.conf

    	#Start wireguard up again
    	sudo systemctl start wg-quick@wg0
    	mv $f /etc/scripts/parsed_config

	touch /etc/scripts/outconf/$hostname.conf
	cat /etc/scripts/vars/int_vars >> /etc/scripts/outconf/$hostname.conf
	( echo "Address = $address" ; echo "" ) >> /etc/scripts/outconf/$hostname.conf
	cat /etc/scripts/vars/peer_vars >> /etc/scripts/outconf/$hostname.conf
	mail -s $hostname"-config" -a /etc/scripts/outconf/$hostname.conf $email <<< 'your config sir'
	mv /etc/scripts/outconf/$hostname.conf /etc/scripts/outconf_old
	the_ip="$(($next_ip + 1))"
	echo "$the_ip" > /etc/scripts/vars/next_ip
    elif [[ -d $VAR ]]; then
        echo "$f is a directory"
    fi
done
