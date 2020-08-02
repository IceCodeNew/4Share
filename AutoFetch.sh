#!/bin/bash

repos_root='/github'
stat_dnsmasq=1
stat_chinaip=1
stat_china_operator_ip=1
# stat_geoipv6=0

# 检查上游是否有更新
cd "$repos_root/dnsmasq-china-list" || exit
git fetch --all
if git status | grep -q "Your branch is up to date with 'origin/master'."; then
    stat_dnsmasq=0
else
    # 将 HEAD 指向上游更新
    git reset --hard origin/master
fi

cd "$repos_root/china_ip_list" || exit
git fetch --all
if git status | grep -q "Your branch is up to date with 'origin/master'."; then
    stat_chinaip=0
else
    git reset --hard origin/master
fi

cd "$repos_root/china-operator-ip" || exit
git fetch --all
if git status | grep -q "Your branch is up to date with 'origin/master'."; then
    stat_china_operator_ip=0
else
    git reset --hard origin/ip-lists
fi

# if date +%d%H%M | grep -q -P '\d[16]0555'; then
#     rm -rf "$repos_root/GeoLite2"
#     mkdir -p "$repos_root/GeoLite2"
#     cd "$repos_root/GeoLite2" || exit
#     wget 'https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=JvbzLLx7qBZT&suffix=zip' -O GeoLite2-Country-CSV.zip
#     unzip GeoLite2-Country-CSV.zip && rm -f GeoLite2-Country-CSV.zip
#     cd GeoLite2-Country-CSV* || exit
# 
#     cn_geoname_id=$(grep -o -P '^\d+(?=,.*"亚洲",CN,"中国".*)' GeoLite2-Country-Locations-zh-CN.csv)
#     sed -i '/'"$cn_geoname_id"'/!d' GeoLite2-Country-Blocks-IPv6.csv
#     sed -i 's/,.*//g' GeoLite2-Country-Blocks-IPv6.csv
#     mv GeoLite2-Country-Blocks-IPv6.csv "$repos_root/china-ipv6.txt"
#     stat_geoipv6=1
# fi

cd "$repos_root/4Share" || exit
# if [ $stat_dnsmasq -ne 0 ] || [ $stat_chinaip -ne 0 ] || [ $stat_geoipv6 -ne 0 ]; then
if [ $stat_dnsmasq -ne 0 ] || [ $stat_chinaip -ne 0 ] || [ $stat_china_operator_ip -ne 0 ]; then
    bash AutoCommit.sh
else
    exit 0
fi
