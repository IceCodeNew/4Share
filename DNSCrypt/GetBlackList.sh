#!/bin/bash

read -rp "Where to download the rules file? "
REPLY=${REPLY//\\/\/}
root_letter=`echo ${REPLY:0:1} | tr '[:upper:]' '[:lower:]'`
REPLY='/mnt/'$root_letter'/'${REPLY:3}
echo "The specified dir is: $REPLY"
unset root_letter
cd $REPLY

wget https://download.dnscrypt.info/blacklists/domains/mybase.txt

sed -i '/.*analy.*/!d' mybase.txt
sed -i '/apa\.me/d' mybase.txt
sed -i '1i\apa\.me' mybase.txt
sed -i -e '/^analy\./d' -e '1a\analy\.\\\*' mybase.txt
sed -i -e '/^analytic\./d' -e '1a\analytic\.\\\*' mybase.txt
sed -i -e '/^analytics\./d' -e '1a\analytics\.\\\*' mybase.txt
sed -i -e '/^analystic\./d' -e '1a\analystic\.\\\*' mybase.txt
sed -i -e '/^analysis\./d' -e '1a\analysis\.\\\*' mybase.txt
sed -i -e '/^analyse\./d' -e '1a\analyse\.\\\*' mybase.txt
sed -i -e '/^analyze\./d' -e '1a\analyze\.\\\*' mybase.txt
sed -i -e '/^analyzer\./d' -e '1a\analyzer\.\\\*' mybase.txt

cp mybase.txt domain-based-blacklist.txt

sed -i -e '/^mobileanalytics\./d' -e '1a\mobileanalytics\.\\\*' domain-based-blacklist.txt
sed -i -e '/^csgosteamanalyst\./d' -e '1a\csgosteamanalyst\.\\\*' domain-based-blacklist.txt
sed -i -e '/businessrulesanalysis\.com$/d' -e '1a\businessrulesanalysis\.com' domain-based-blacklist.txt
