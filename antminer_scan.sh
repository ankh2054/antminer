#!/usr/bin/env bash

which curl > /dev/null || (echo -e "curl is required, try apt-get install curl" && exit 1)

function usage() {
    bname=`basename $0`
    echo -e "Usage example 1: $bname 192.168.0.0/24"
    echo -e "Usage example 2: $bname 192.168.0.0/24 192.168.100.0/24"
    echo -e "Usage example 3: $bname 172.16.1.0/16 192.168.1.0/24 10.0.1.0/24"
    echo -e "Usage example 4: $bname 192.168.0.0/24 > ips.txt"
}

prefix_to_bit_netmask() {
    prefix=$1;
    shift=$(( 32 - prefix ));

    bitmask=""
    for (( i=0; i < 32; i++ )); do
        num=0
        if [ $i -lt $prefix ]; then
            num=1
        fi

        space=
        if [ $(( i % 8 )) -eq 0 ]; then
            space=" ";
        fi

        bitmask="${bitmask}${space}${num}"
    done
    echo $bitmask
}

bit_netmask_to_wildcard_netmask() {
    bitmask=$1;
    wildcard_mask=
    for octet in $bitmask; do
        wildcard_mask="${wildcard_mask} $(( 255 - 2#$octet ))"
    done
    echo $wildcard_mask;
}

mkdir -p /dev/shm/ip
rm -rf /dev/shm/ip/*

for ip in $@; do
    net=$(echo $ip | cut -d '/' -f 1);
    prefix=$(echo $ip | cut -d '/' -f 2);

 bit_netmask=$(prefix_to_bit_netmask $prefix);

    wildcard_mask=$(bit_netmask_to_wildcard_netmask "$bit_netmask");

    str=
    for (( i = 1; i <= 4; i++ )); do
        range=$(echo $net | cut -d '.' -f $i)
        mask_octet=$(echo $wildcard_mask | cut -d ' ' -f $i)
        if [ $mask_octet -gt 0 ]; then
            range="{0..$mask_octet}";
        fi
        str="${str} $range"
    done
    ips=$(echo $str | sed "s, ,\\.,g"); ## replace spaces with periods, a join...
#    eval echo $ips | tr ' ' '\012'
    echo > /dev/shm/ips
    for i in $(eval echo $ips | tr ' ' '\012'); do curl -v -s -m 5 $i:80 2>&1 | grep "antMiner Configuration" > /dev/null && touch /dev/shm/ip/$i & sleep 0.1; done
    wait
done

eval ls /dev/shm/ip/ | tr ' ' '\012' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4

rm -rf /dev/shm/ip/*
[[ -z $1 ]] && usage
