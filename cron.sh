#!/bin/bash

sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

if [[ -f /usr/sbin/haproxy ]]; then
    wget --no-check-certificate https://github.com/ActiveIce/xuewaiyu/raw/master/haproxy.tar.gz
    tar xzf haproxy.tar.gz -C /usr/sbin haproxy
    rm haproxy.tar.gz
fi
if [[ -f /usr/bin/v2ray/v2ray ]]; then
    wget --no-check-certificate https://github.com/ActiveIce/xuewaiyu/raw/master/xwy-linux.tar.gz
    tar xzf xwy-linux.tar.gz -C /usr/bin/v2ray v2ray v2ctl geoip.dat geosite.dat
    rm xwy-linux.tar.gz
fi

sudo reboot
exit 0
