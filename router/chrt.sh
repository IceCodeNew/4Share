#!/bin/sh

script_path="/tmp/mnt/router/configs"
list_path="/tmp/mnt/router/dnsmasq.d"

if [ $# -ne 1 ]; then
    echo $0 add/del/upd
    exit
fi

if [ "$1" == "add" ]; then
    chmod a+rx ${script_path}/*

    "${script_path}/route.sh" add && echo -e "\n  Add route success!\n"
elif [ "$1" == "del" ]; then
    chmod a+rx ${script_path}/*

    "${script_path}/route.sh" delete && echo -e "\n  Delete route success!\n"
elif [ "$1" == "upd" ]; then
    curl -o "${script_path}/route.sh.new" https://raw.githubusercontent.com/IceCodeNew/4Share/master/router/route.sh \
    && mv "${script_path}/route.sh.new" "${script_path}/route.sh" -f && echo -e "\n  Update route.sh success!\n"

    curl -o "${list_path}/accelerated-domains.china.conf.new" \
    https://raw.githubusercontent.com/IceCodeNew/4Share/master/router/accelerated-domains.china.conf && \
    mv "${list_path}/accelerated-domains.china.conf.new" "${list_path}/accelerated-domains.china.conf" -f \
    && echo -e "\n  Update accelerated-domains.china.conf success!\n"

    service restart_dnsmasq && echo -e "\n  Restart dnsmasq success!\n"
    /opt/etc/init.d/S54pcap_dnsproxy restart && echo -e "\n  Restart pcap_dnsproxy success!\n"
else
    echo $0 add/del/upd
    exit
fi