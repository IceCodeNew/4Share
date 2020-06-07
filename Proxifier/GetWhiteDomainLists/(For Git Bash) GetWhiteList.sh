#!/bin/bash

# read -rp "Where to download the rules file? "
# REPLY=${REPLY//\\/\/}
# root_letter=`echo ${REPLY:0:1} | tr '[:upper:]' '[:lower:]'`
# REPLY='/'$root_letter'/'${REPLY:3}
# echo "The specified dir is: $REPLY"
# unset root_letter
# cd $REPLY

set -x

cd "$(dirname "$0")" || exit
rm -r 'downloaded_rules/' 'whitelist.txt' 'icn_temp.txt'
if [ ! -f 'ori_white_domains.txt' ]; then
    rm ori_white_domains.txt
    touch ori_white_domains.txt
fi

cp 'ori_white_domains.txt' 'icn_temp.txt'
dos2unix -- ./*.txt ./*.py
winpty "$(which python)" 'gwl.py'

(
cd 'downloaded_rules' || exit
dos2unix -- ./*
# find . -maxdepth 1 -type f -print0 | xargs -0 sed -i -E -e '/^include:/d' -e 's/[^\S\r\n]*#[^\r\n]*//g'
find . -maxdepth 1 -type f -print0 | xargs -0 sed -i -E -e '/^include:/d' -e 's/[\t ]*#[^\r\n]*//g'
find . -maxdepth 1 -type f -print0 | xargs -0 sed -i -E -e '/^$/d' -e 's/^/\*\./g'

find . -maxdepth 1 -type f -print0 | xargs -0 cat >> '../icn_temp.txt'
# cat <(find . -maxdepth 1 -type f -print0 | xargs -0 cat) '../icn_temp.txt' | sort | uniq > '../whitelist.txt'
)

sed -i -E -e 's/\s//g' -e 's/\*\./\n\*\./g' -e '$a\''\n' icn_temp.txt
< 'icn_temp.txt' sort | uniq > whitelist.txt
sed -E -i '/^\s*$/d' whitelist.txt && dos2unix -- ./*.txt
rm -r 'downloaded_rules/' 'icn_temp.txt'

set +x
