#!/bin/bash

#
# Use this script to quickly check if your traffic is seen as traffic from a tor node.
#
# This script obtains your IP address from 'api.ipify.org' and then attempts to download
# an html page from obtained IP address.
#
# If that IP address returns a webpage, it is compared to a webpage usually returned by
# a tor node.
# 
# Requirements: bash
#

ip=$(curl -s 'api.ipify.org')
echo "Detected IP address: ${ip}"

if [ $? -ne 0 ]
then
    echo "Failed to get the ip address!"
    exit 1
fi

page=$(wget -q -O - $ip)

if [ $? -ne 0 ]
then
    echo "Failed to get the http page from ${ip}!"
    echo "This means you either have a bad internet connection,"
    echo "or the ip address does not serve as a website host."
    echo "Can't determine if you are using tor."
    exit 1
fi

echo "$page" | grep -q -E '<h1>This is a Tor Exit Node</h1>|<h1>This is a Tor Exit Router</h1>|Tor Anonymity Network|Most likely you are accessing this website because you had some issue with
the traffic coming from this IP.'

if [ $? -ne 0 ]
then
    echo "Can't determine if you are using tor."
else
    echo "Your traffic seems to be coming from a tor exit node."
fi
