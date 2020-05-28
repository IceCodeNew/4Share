#!/bin/bash

# read -rp "Where to download the rules file? "
# REPLY=${REPLY//\\/\/}
# root_letter=`echo ${REPLY:0:1} | tr '[:upper:]' '[:lower:]'`
# REPLY='/'$root_letter'/'${REPLY:3}
# echo "The specified dir is: $REPLY"
# unset root_letter
# cd $REPLY

cd "$(dirname "$0")" || exit
cd '../../dnscrypt-proxy/utils/generate-domains-blacklists/' || exit
git fetch --all && git reset --hard origin/master > /dev/null 2>&1

sed -E -i 's!(^https:\/\/raw\.githubusercontent\.com\/EnergizedProtection\/block\/master\/blu\/formats\/domains\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/raw\.githubusercontent\.com\/CHEF-KOCH\/Spotify-Ad-free\/master\/filters\/Spotify-HOSTS\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/raw\.githubusercontent\.com\/CHEF-KOCH\/NSABlocklist\/master\/HOSTS\/HOSTS)!# \1!' domains-blacklist.conf
# sed -E -i 's!(^https:\/\/raw\.githubusercontent\.com\/crazy-max\/WindowsSpyBlocker\/master\/data\/dnscrypt\/spy\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/hostfiles\.frogeye\.fr\/firstparty-trackers\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/raw\.githubusercontent\.com\/notracking\/hosts-blocklists\/master\/dnscrypt-proxy\/dnscrypt-proxy\.blacklist\.txt)!# \1!' domains-blacklist.conf
# sed -E -i 's!(^https:\/\/s3\.amazonaws\.com\/lists\.disconnect\.me\/simple_malvertising\.txt)!# \1!' domains-blacklist.conf
# sed -E -i 's!(^https:\/\/s3\.amazonaws\.com\/lists\.disconnect\.me\/simple_tracking\.txt)!# \1!' domains-blacklist.conf
# sed -E -i 's!(^https:\/\/s3\.amazonaws\.com\/lists\.disconnect\.me\/simple_ad\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/raw\.githubusercontent\.com\/Spam404\/lists\/master\/main-blacklist\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/www\.malwaredomainlist\.com\/hostslist\/hosts\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/mirror1\.malwaredomains\.com\/files\/justdomains)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/easylist-downloads\.adblockplus\.org\/easylistchina\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/easylist-downloads\.adblockplus\.org\/easylist_noelemhide\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/adguardteam\.github\.io\/AdGuardSDNSFilter\/Filters\/filter\.txt)!# \1!' domains-blacklist.conf
# sed -E -i 's!(^https:\/\/ssl\.bblck\.me\/blacklists\/domain-list\.txt)!# \1!' domains-blacklist.conf

# Append ```os._exit(0)``` and ```import os```
python -i generate-domains-blacklist.py > mybase.txt

# sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/EnergizedProtection\/block\/master\/blu\/formats\/domains\.txt)!\1!' domains-blacklist.conf
# sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/CHEF-KOCH\/Spotify-Ad-free\/master\/filters\/Spotify-HOSTS\.txt)!\1!' domains-blacklist.conf
# sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/CHEF-KOCH\/NSABlocklist\/master\/HOSTS\/HOSTS)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/crazy-max\/WindowsSpyBlocker\/master\/data\/dnscrypt\/spy\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/hostfiles\.frogeye\.fr\/firstparty-trackers\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/notracking\/hosts-blocklists\/master\/dnscrypt-proxy\/dnscrypt-proxy\.blacklist\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/s3\.amazonaws\.com\/lists\.disconnect\.me\/simple_malvertising\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/s3\.amazonaws\.com\/lists\.disconnect\.me\/simple_tracking\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/s3\.amazonaws\.com\/lists\.disconnect\.me\/simple_ad\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/Spam404\/lists\/master\/main-blacklist\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/www\.malwaredomainlist\.com\/hostslist\/hosts\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/mirror1\.malwaredomains\.com\/files\/justdomains)!\1!' domains-blacklist.conf
# sed -E -i 's!^# (https:\/\/easylist-downloads\.adblockplus\.org\/easylistchina\.txt)!\1!' domains-blacklist.conf
# sed -E -i 's!^# (https:\/\/easylist-downloads\.adblockplus\.org\/easylist_noelemhide\.txt)!\1!' domains-blacklist.conf
# sed -E -i 's!^# (https:\/\/adguardteam\.github\.io\/AdGuardSDNSFilter\/Filters\/filter\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/ssl\.bblck\.me\/blacklists\/domain-list\.txt)!\1!' domains-blacklist.conf

python -i generate-domains-blacklist.py > domain-based-blacklist.txt

################################################################

/bin/mv -f mybase.txt domain-based-blacklist.txt "$(dirname "$0")"
cd "$(dirname "$0")"
/bin/rm -f '../v2rayN/v2rayN_block_rules.txt' '../v2rayN/Advertising.list' '../v2rayN/Hijacking.list'

dos2unix fws.py ./*.txt
winpty "$(which python)" fws.py

/bin/mv -f v2rayN_block_rules.txt '../v2rayN'
cd '../v2rayN'
curl -o Advertising.list 'https://raw.githubusercontent.com/ConnersHua/Profiles/master/Quantumult/X/Filter/Advertising.list'
curl -o Hijacking.list 'https://raw.githubusercontent.com/ConnersHua/Profiles/master/Quantumult/X/Filter/Hijacking.list'
sed -E -i -e '/^#|^$/d' -e '/^DOMAIN-KEYWORD.*/d' -e '/^DOMAIN/!d' -e '/REJECT$/!d' Advertising.list Hijacking.list
sed -E -i -e 's/REJECT$//' -e 's/^DOMAIN,/full:/' -e 's/^DOMAIN-SUFFIX,/domain:/' Advertising.list Hijacking.list

if [ ! -f 'ori_BlackList.txt' ]; then
    rm -rf -- 'ori_BlackList.txt'
    touch 'ori_BlackList.txt'
fi
cat ori_BlackList.txt v2rayN_block_rules.txt Advertising.list Hijacking.list | sort | uniq > temp_v2rayN_block_rules.txt
/bin/mv -f temp_v2rayN_block_rules.txt v2rayN_block_rules.txt
dos2unix ./*.txt
