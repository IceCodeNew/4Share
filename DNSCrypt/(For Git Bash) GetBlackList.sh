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
sed -E -i 's!(^https:\/\/isc\.sans\.edu\/feeds\/suspiciousdomains_High\.txt)!# \1!' domains-blacklist.conf
sed -E -i 's!(^https:\/\/raw\.githubusercontent\.com\/AdAway\/adaway\.github\.io\/master\/hosts\.txt)!# \1!' domains-blacklist.conf

sed -E -i '/^# custom_blacklist\.txt$/,$d' domains-blacklist.conf
# Append ```os._exit(0)``` and ```import os```
python -i generate-domains-blacklist.py > mybase.txt

################################################################

/bin/mv -f mybase.txt "$(dirname "$0")"
cd "$(dirname "$0")" || exit
/bin/rm -f '../v2rayN/v2rayN_block_rules.txt' '../v2rayN/custom_blacklist.txt'

dos2unix fws.py ./*.txt
winpty "$(which python)" fws.py

/bin/mv -f v2rayN_block_rules.txt '../v2rayN'
cd '../v2rayN'
# curl -o AdBlock.list.new 'https://raw.githubusercontent.com/GeQ1an/Rules/master/QuantumultX/Filter/AdBlock.list' && sed -E -i 's/^HOST/DOMAIN/g' AdBlock.list.new && mv AdBlock.list.new AdBlock.list;
curl -o Advertising.list.new 'https://raw.githubusercontent.com/ConnersHua/Profiles/master/Quantumult/X/Filter/Advertising.list' && mv Advertising.list.new Advertising.list;
curl -o Hijacking.list.new 'https://raw.githubusercontent.com/ConnersHua/Profiles/master/Quantumult/X/Filter/Hijacking.list' && mv Hijacking.list.new Hijacking.list;
# curl -o Reject.list.new 'https://raw.githubusercontent.com/lhie1/Rules/master/Surge/Surge%203/Provider/Reject.list' && mv Reject.list.new Reject.list;

sed -E -i -e '/^#|^$/d' -e '/^DOMAIN/!d' -e '/^DOMAIN-KEYWORD.*/d' AdBlock.list Advertising.list Hijacking.list Reject.list
sed -E -i -e 's/REJECT$//g' -e 's/AdBlock$//g' -e 's/^DOMAIN,/full:/g' -e 's/^DOMAIN-SUFFIX,/domain:/g' AdBlock.list Advertising.list Hijacking.list Reject.list

if [ ! -f 'ori_BlackList.txt' ]; then
    rm -rf -- 'ori_BlackList.txt'
    touch 'ori_BlackList.txt'
fi
cat ori_BlackList.txt AdBlock.list Advertising.list Hijacking.list Reject.list | sort | uniq > custom_blacklist.txt
cat v2rayN_block_rules.txt custom_blacklist.txt | sort | uniq > temp_v2rayN_block_rules.txt
/bin/mv -f temp_v2rayN_block_rules.txt v2rayN_block_rules.txt

dos2unix ./*.txt

################################################################

/bin/mv -f custom_blacklist.txt "$REPOS_ROOT/dnscrypt-proxy/utils/generate-domains-blacklists/custom_blacklist.txt"
cd "$(dirname "$0")" || exit
cd '../../dnscrypt-proxy/utils/generate-domains-blacklists/' || exit

# sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/EnergizedProtection\/block\/master\/blu\/formats\/domains\.txt)!\1!' domains-blacklist.conf
# sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/CHEF-KOCH\/Spotify-Ad-free\/master\/filters\/Spotify-HOSTS\.txt)!\1!' domains-blacklist.conf
# sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/CHEF-KOCH\/NSABlocklist\/master\/HOSTS\/HOSTS)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/crazy-max\/WindowsSpyBlocker\/master\/data\/dnscrypt\/spy\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/hostfiles\.frogeye\.fr\/firstparty-trackers\.txt)!\1!' domains-blacklist.conf
# sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/notracking\/hosts-blocklists\/master\/dnscrypt-proxy\/dnscrypt-proxy\.blacklist\.txt)!\1!' domains-blacklist.conf
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
sed -E -i 's!^# (https:\/\/isc\.sans\.edu\/feeds\/suspiciousdomains_High\.txt)!\1!' domains-blacklist.conf
sed -E -i 's!^# (https:\/\/raw\.githubusercontent\.com\/AdAway\/adaway\.github\.io\/master\/hosts\.txt)!\1!' domains-blacklist.conf

sed -E -i '$a\# custom_blacklist.txt\nfile:custom_blacklist.txt' domains-blacklist.conf
python -i generate-domains-blacklist.py > domain-based-blacklist.txt

################################################################

/bin/mv -f mybase.txt domain-based-blacklist.txt "$(dirname "$0")"
