#!/bin/bash

wget https://download.dnscrypt.info/blacklists/domains/mybase.txt
sed -i '/.*analy.*/!d' mybase.txt
sed -i '/apa\.me/d' mybase.txt
sed -i '1i\apa\.me' mybase.txt
sed -i -e '/^analy\./d' -e '/apa\.me/a\analy\.\\\*' mybase.txt
sed -i -e '/^analytic\./d' -e '/apa\.me/a\analytic\.\\\*' mybase.txt
sed -i -e '/^analytics\./d' -e '/apa\.me/a\analytics\.\\\*' mybase.txt
sed -i -e '/^analysis\./d' -e '/apa\.me/a\analysis\.\\\*' mybase.txt
sed -i -e '/^analyze\./d' -e '/apa\.me/a\analyze\.\\\*' mybase.txt
sed -i -e '/^analyzer\./d' -e '/apa\.me/a\analyzer\.\\\*' mybase.txt
mv mybase.txt domain-based-blacklist.txt
