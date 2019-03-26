#!/bin/bash

# read -rp "Where to download the rules file? "
# REPLY=${REPLY//\\/\/}
# root_letter=`echo ${REPLY:0:1} | tr '[:upper:]' '[:lower:]'`
# REPLY='/'$root_letter'/'${REPLY:3}
# echo "The specified dir is: $REPLY"
# unset root_letter
# cd $REPLY

cd "$(dirname "$0")"
rm -rf 'downloaded_rules/'
rm -f 'whitelist.txt' 'icn_temp.txt'
if [ ! -f 'ori_white_domains.txt' ]; then
    rm -rf ori_white_domains.txt
    touch ori_white_domains.txt
fi

cp 'ori_white_domains.txt' 'icn_temp.txt'
dos2unix ./*.txt
dos2unix *.py
winpty "$(which python)" 'gwl.py'

cd 'downloaded_rules'
dos2unix ./*
find . -maxdepth 1 -type f -print0 | xargs -0 sed -i -r -e '/^include:/d' -e 's/\s*#.*//g'
find . -maxdepth 1 -type f -print0 | xargs -0 sed -i -r -e '/^$/d' -e 's/^/\*\./g'

cat <(find . -maxdepth 1 -type f -print0 | xargs -0 cat) '../icn_temp.txt' | sort | uniq >> '../whitelist.txt'
rm '../icn_temp.txt'
