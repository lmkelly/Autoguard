#!/bin/bash

inotifywait -r -e create -m --format '%w%f' /etc/incoming_config | \
    while read f; do
    VAR=$f
    if [[ -f $VAR ]]; then
      sudo systemctl stop wg-quick@wg0

    	#Get the most recently used IP
    	next_ip=$(tail -2 /etc/wireguard/wg0.conf)

    	#Splice around the IP so you get the next avalable IP
    	HOST=$(echo $next_ip | cut -d '.' -f 4 | cut -d '/' -f 1)
    	ahost=$(echo $next_ip | cut -d '/' -f 1 | cut -d '.' -f 1)
    	bhost=$(echo $next_ip | cut -d '/' -f 1 | cut -d '.' -f 2)
    	chost=$(echo $next_ip | cut -d '/' -f 1 | cut -d '.' -f 3)

    	shost=$(echo $next_ip | cut -d '/' -f 2 | cut -d 'E' -f 1)

    	#Splice config file
    	config=$(tail $f)
    	pub_key=$(echo $config |cut -d '*' -f 1)
    	endpoint=$(echo $config |cut -d '*' -f 2)
 
    	#Add 1 to the most recent IP
    	DHOST="$(($HOST+1))"

    	# Formet the new peer line
    	printf '\n[Peer]\n' >> /etc/wireguard/wg0.conf
    	echo $pub_key >> /etc/wireguard/wg0.conf
    	echo $ahost"."$bhost"."$chost"."$DHOST"/"$shost >> /etc/wireguard/wg0.conf
    	echo $endpoint >> /etc/wireguard/wg0.conf

    	#Start wireguard up again
    	sudo systemctl start wg-quick@wg0
    	mv $f /etc/scripts/parsed_config
    elif [[ -d $VAR ]]; then
        echo "$f is a directory"
    fi
done
