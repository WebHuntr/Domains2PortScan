#!/bin/bash

#This app was built to take a list of domains and convert them into IP addresses, and then portscan those IP addresses.

#Errors out if 2 parameters are not received and outputs correct usage information
if [ "$#" -lt 1 ]; then
	echo " Use:$basename "$0" [input_file]"
	exit
fi

input_file=$1
output_file=$2

#Performs NSlookup on every domain, outputting the IP addresses to "temp.txt"
while read -r domain; do
    echo $domain
    ip=$(nslookup $domain | grep 'Address' | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | awk 'NR==2{print}')
    if [ -n "$ip" ]; then
	echo $ip
        echo "$ip" >> "temp.txt"
    fi
done < "$input_file"
    
#Removes duplicates from temp.txt
awk -i inplace '!seen[$0]++' ./temp.txt

#Opens temp.txt and runs a fast port scan just to find open ports
file=temp.txt
while read -r ip;
do
naabu $ip -rate 250 -c 15 > output.txt
echo "$ip Done"
done < "temp.txt"

#Removes duplicates from output.txt
awk -i inplace '!seen[$0]++' ./output.txt

#Clean up temp files
rm temp.txt

