#!/bin/bash

read -rp "Where to download the rules file? "
REPLY=${REPLY//\\/\/}
root_letter=`echo ${REPLY:0:1} | tr '[:upper:]' '[:lower:]'`
REPLY='/mnt/'$root_letter'/'${REPLY:3}
echo "The specified dir is: $REPLY"
unset root_letter
cd $REPLY

rm domain-based-blacklist.txt mybase.txt
wget https://download.dnscrypt.info/blacklists/domains/mybase.txt

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

sed -i -e '/^nj\.baidupcs\.com$/d' -e '1i\nj\.baidupcs\.com' domain-based-blacklist.txt
