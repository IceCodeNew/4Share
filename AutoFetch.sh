#!/bin/bash

REPOS_ROOT='/github'
stat_dnsmasq=1
stat_chinaip=1
stat_geoipv6=0

# 检查上游是否有更新
cd "$REPOS_ROOT/dnsmasq-china-list" || exit
git fetch --all > /dev/null 2>&1
if git status | grep -q "Your branch is up to date with 'origin/master'."; then
    stat_dnsmasq=0
else
    # 将 HEAD 指向上游更新
    git reset --hard origin/master
fi

cd "$REPOS_ROOT/china_ip_list" || exit
git fetch --all > /dev/null 2>&1
if git status | grep -q "Your branch is up to date with 'origin/master'."; then
    stat_chinaip=0
else
    git reset --hard origin/master
fi

if date +%d%H%M | grep -q -P '\d[16]0555'; then
    cd "$REPOS_ROOT/GeoLite2" || exit
    wget 'https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=JvbzLLx7qBZT&suffix=zip' -O GeoLite2-Country-CSV.zip
    unzip GeoLite2-Country-CSV.zip && rm -f GeoLite2-Country-CSV.zip
    cd GeoLite2-Country-CSV* || exit

    cn_geoname_id=$(grep -o -P '^\d+(?=,.*"亚洲",CN,"中国".*)' GeoLite2-Country-Locations-zh-CN.csv)
    sed -i '/'"$cn_geoname_id"'/!d' GeoLite2-Country-Blocks-IPv6.csv
    sed -i 's/,.*//g' GeoLite2-Country-Blocks-IPv6.csv
    mv GeoLite2-Country-Blocks-IPv6.csv "$REPOS_ROOT/china-ipv6.txt"
    cd .. && find . -print0 | parallel -0 rm -rf -- "{}"
    stat_geoipv6=1
fi

cd "$REPOS_ROOT/4Share" || exit
if [ $stat_dnsmasq -ne 0 ] || [ $stat_chinaip -ne 0 ] || [ $stat_geoipv6 -ne 0 ]; then
    bash AutoCommit.sh
else
    exit 0
fi
