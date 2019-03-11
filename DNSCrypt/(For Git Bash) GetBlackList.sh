#!/bin/bash

# read -rp "Where to download the rules file? "
# REPLY=${REPLY//\\/\/}
# root_letter=`echo ${REPLY:0:1} | tr '[:upper:]' '[:lower:]'`
# REPLY='/'$root_letter'/'${REPLY:3}
# echo "The specified dir is: $REPLY"
# unset root_letter
# cd $REPLY

cd "$(dirname "$0")"

rm domain-based-blacklist.txt mybase.txt extra.txt spy.txt DNSCrypt_black_list.txt
rm '../v2rayN／v2rayNG/v2rayN_block_rules.txt'

curl -O https://download.dnscrypt.info/blacklists/domains/mybase.txt
curl -O https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/dnscrypt/extra.txt
curl -O https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/dnscrypt/spy.txt
dos2unix fws.py

sed -i '/.*analy.*/!d' mybase.txt
sed -i -e '/^analy\./d' -e '1i\analy\.\\\*' mybase.txt
sed -i -e '/^analytic\./d' -e '1i\analytic\.\\\*' mybase.txt
sed -i -e '/^analytics\./d' -e '1i\analytics\.\\\*' mybase.txt
sed -i -e '/^analystic\./d' -e '1i\analystic\.\\\*' mybase.txt
sed -i -e '/^analysis\./d' -e '1i\analysis\.\\\*' mybase.txt
sed -i -e '/^analyse\./d' -e '1i\analyse\.\\\*' mybase.txt
sed -i -e '/^analyze\./d' -e '1i\analyze\.\\\*' mybase.txt
sed -i -e '/^analyzer\./d' -e '1i\analyzer\.\\\*' mybase.txt
cp mybase.txt domain-based-blacklist.txt

sed -i '/apa\.me/d' domain-based-blacklist.txt
sed -i '/skkdd\.com/d' domain-based-blacklist.txt
sed -i '1i\apa\.me' domain-based-blacklist.txt
sed -i '1i\skkdd\.com' domain-based-blacklist.txt

sed -i -e '/^mobileanalytics\./d' -e '1i\mobileanalytics\.\\\*' domain-based-blacklist.txt
sed -i -e '/^csgosteamanalyst\./d' -e '1i\csgosteamanalyst\.\\\*' domain-based-blacklist.txt
sed -i -e '/businessrulesanalysis\.com$/d' -e '1i\businessrulesanalysis\.com' domain-based-blacklist.txt
sed -i -e '/doubleclick\.net$/d' -e '1i\doubleclick\.net' domain-based-blacklist.txt

sed -i -e '/^nj\.baidupcs\.com$/d' -e '1i\nj\.baidupcs\.com' domain-based-blacklist.txt

winpty "$(which python)" fws.py
unix2dos ./*.txt
cat domain-based-blacklist.txt DNSCrypt_black_list.txt | sort | uniq > domain-based-blacklist.txt
rm DNSCrypt_black_list.txt spy.txt extra.txt

mv v2rayN_block_rules.txt '../v2rayN／v2rayNG'
cd '../v2rayN／v2rayNG'
if [ ! -f 'ori_BlackList.txt' ]; then
    rm -rf ori_BlackList.txt
    touch ori_BlackList.txt
fi
cat ori_BlackList.txt v2rayN_block_rules.txt | sort | uniq > v2rayN_block_rules.txt
unix2dos ./*.txt
