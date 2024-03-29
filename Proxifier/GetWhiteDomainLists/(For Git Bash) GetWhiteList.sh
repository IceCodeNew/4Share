#!/bin/bash

# read -rp "Where to download the rules file? "
# REPLY=${REPLY//\\/\/}
# root_letter=`echo ${REPLY:0:1} | tr '[:upper:]' '[:lower:]'`
# REPLY='/'$root_letter'/'${REPLY:3}
# echo "The specified dir is: $REPLY"
# unset root_letter
# cd $REPLY

set -x

cd "$(dirname "$0")" || exit 1
rm -r 'downloaded_rules/' 'extra_dlc_cn.txt' 'whitelist.txt' 'scholar_not_cn.txt' 'tmp_whitelist.txt' 'tmp_scholar_not_cn.txt'

# winpty "$(which python)" 'start_yield.py' 'cn' 'category-scholar-!cn'
curl -LR 'https://raw.githubusercontent.com/IceCodeNew/domain-list-custom/release/cn.txt' -o 'tmp_whitelist.txt'
curl -LR 'https://raw.githubusercontent.com/IceCodeNew/domain-list-community/release/category-scholar-!cn.txt' -o 'tmp_scholar_not_cn.txt'
find . -type f -print0 | xargs -0 dos2unix

# (
# cd 'downloaded_rules' || exit 1
# while :
# do
#     find 'geolocation-cn.d' -maxdepth 1 -type f -print0 | xargs -0 sed -E -e '/^#|^$/d' -e 's/[\t ]*#[^\r\n]*//g' | winpty "$(which python)" '../deep_diger.py' 'geolocation-cn'
#     [[ ! -d 'geolocation-cn.d' ]] && break
# done
# sed -i -E -e 's/[\t ]*[#@][^\r\n]*//g' -e '/^#|^$|^\*\.$/d' 'geolocation-cn'
# sed -i -E -e '/\.googleapis\.|\.gstatic\.|\.recaptcha\.|\.ampproject\./d' 'geolocation-cn'
# mv 'geolocation-cn' '../tmp_whitelist.txt'
# 
# while :
# do
#     rm 'category-scholar-!cn.d/google-scholar'
#     find 'category-scholar-!cn.d' -maxdepth 1 -type f -print0 | xargs -0 sed -E -e '/^#|^$/d' -e 's/[\t ]*#[^\r\n]*//g' | winpty "$(which python)" '../deep_diger.py' 'category-scholar-!cn'
#     [[ ! -d 'geolocation-cn.d' ]] && break
# done
# sed -i -E -e 's/[\t ]*[#@][^\r\n]*//g' -e '/^#|^$|^\*\.$/d' 'category-scholar-!cn'
# mv 'category-scholar-!cn' '../tmp_scholar_not_cn.txt'
# )

[[ -f 'ori_white_domains.txt' ]] && cat 'ori_white_domains.txt' >> 'tmp_whitelist.txt' \
&& sed -E -e 's/\*\./domain:/' -e 's/^/full:/' -e 's/full:domain:/domain:/' 'ori_white_domains.txt' > 'extra_dlc_cn.txt'

sed -E -i -e '/[-@]ads|^regexp:|scholar\.google|\.and|\.chrome|\.dclk|\.gbiz|\.gle|\.gmail|\.goo|\.goog|\.google|\.guge|\.hangout|\.nexus|\.xn--qcka1pmc|\.youtube|crashlytics\.com|doubleclick\.net|gstatic\.com|gvt2\.com|google\.com|googleadservices\.com|google-?analytics\.com|googleapis\.com|googletagmanager\.com|googletagservices\.com|recaptcha\.net$/d' -e 's/:@cn$//' -e 's/full://' -e 's/domain:/\*\./' 'tmp_whitelist.txt' 'tmp_scholar_not_cn.txt'
perl -ni -e 'print unless /(?<!^\*)\.(baidu|citic|cn|sohu|unicom|xn--1qqw23a|xn--6frz82g|xn--8y0a063a|xn--estv75g|xn--fiq64b|xn--fiqs8s|xn--fiqz9s|xn--vuq861b|xn--xhq521b|xn--zfr164b)$/' 'tmp_whitelist.txt'
sed -E -i '/^[\t\f\v ]*$/d' 'tmp_whitelist.txt' 'tmp_scholar_not_cn.txt'
< 'tmp_whitelist.txt' sort -u -o 'whitelist.txt'
< 'tmp_scholar_not_cn.txt' sort -u -o 'scholar_not_cn.txt'
dos2unix -- ./*.txt
rm -r 'downloaded_rules/' 'tmp_whitelist.txt' 'tmp_scholar_not_cn.txt'

set +x
