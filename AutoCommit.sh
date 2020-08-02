#!/bin/bash

repos_root='/github'

cd "$repos_root/4Share/" || exit
# 清理当前目录下所有将由脚本更新的文件，确保不会保留任何旧文件
find . -type f -iname route.sh -print0 | xargs -0 rm --
find . -type f -iname china_ip_list.txt -print0 | xargs -0 rm --
find . -type f -iname china-ipv4.txt -print0 | xargs -0 rm --
find . -type f -iname china-ipv6.txt -print0 | xargs -0 rm --
find . -type f -iregex ".*ip.*_list_.?.txt" -print0 | xargs -0 rm --
find . -type f -iname accelerated-domains.china.conf -print0 | xargs -0 rm --

# 拷贝最新文件
/bin/cp -f "$repos_root/dnsmasq-china-list/accelerated-domains.china.conf" ./
/bin/cp -f "$repos_root/china_ip_list/china_ip_list.txt" ./
/bin/cp -f "$repos_root/china-operator-ip/china.txt" ./china-ipv4.txt
/bin/cp -f "$repos_root/china-operator-ip/china6.txt" ./china-ipv6.txt
fromdos china_ip_list.txt china-ipv6.txt accelerated-domains.china.conf

# 针对北京大学校园网划分网段进行特殊处理
sed -i -E '/^115\.27\.0\.0.*/d' china_ip_list.txt china-ipv4.txt
sed -i -E '/^162\.105\.0\.0.*/d' china_ip_list.txt china-ipv4.txt
sed -i -E '/^202\.112\.7\.0.*/d' china_ip_list.txt china-ipv4.txt
sed -i -E '/^202\.112\.8\.0.*/d' china_ip_list.txt china-ipv4.txt
sed -i -E '/^222\.29\.0\.0.*/d' china_ip_list.txt china-ipv4.txt
sed -i -E '/^222\.29\.128\.0.*/d' china_ip_list.txt china-ipv4.txt
sed -i -E '/^2001:da8:201::.*/d' china-ipv6.txt

# 创建用于写入 Proxifier 规则的 IP 白名单列表
# 1. Proxifier 规则暂不支持 CIDR 格式的 IP 地址，因此需要做格式上的转换
# 2. Proxifier 一条规则内最大能写入 32767 个字符，远远小于格式转换后的 IP 列表字符长，
#    因此需要将 china_ip_list 拆分为多个规则。
fromdos Proxifier/IPConvert.py Proxifier/IPv6Convert.py
python3 Proxifier/IPConvert.py
python3 Proxifier/IPv6Convert.py
/bin/mv -f ip_list_?.txt ipv6_list_?.txt Proxifier
/bin/cp -f china_ip_list.txt geoip_china/china_ip_list.txt

# 通过 sed 命令处理之
sed -i -E -e '/^#|^$/d' -e '/Disable/d' accelerated-domains.china.conf
sed -i -E -e 's/114.114.114.114/223.5.5.5/g' -e '/^server=\/tsdm/d' accelerated-domains.china.conf
sed -i -E -e "s/^/route\ \${OPS}\ -net\ &/g" -e "s/$/&\ \${ROUTE_GW}/g" china_ip_list.txt

# 建立 route.sh 文件
cat > route.sh << 'END_TEXT'
#/bin/bash
#export PATH="/bin:/sbin:/usr/sbin:/usr/bin"

ROUTE_GW="gw `nvram get wan0_gateway`"

if [ $# -ne 1 ]; then
    echo $0 add/delete
    exit
fi

if [ "$1" != "add" ]  && [ "$1" != "delete" ]; then
    echo $0 add/delete
    exit
fi

if [ "$1" == "delete" ]; then
    ROUTE_GW=""
fi

OPS=$1

# route $OPS -net ${IP_SEGMENT} ${ROUTE_GW}
# Generate:
# wget -qo- https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt
# sed -i -E -e 's/^/route\ \${OPS}\ -net\ &/g' -e 's/$/&\ \${ROUTE_GW}/g' china_ip_list.txt

# 另一边要用到的命令：
# wget -qo- https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
# sed -i -E 's/114.114.114.114/223.5.5.5/g' accelerated-domains.china.conf

END_TEXT

cat china_ip_list.txt >> route.sh

cat >> route.sh << 'END_TEXT'

# https://its.pku.edu.cn/faq.jsp  --获得北大IP网段
# 162.105.0.0/16
# 202.112.7.0/24
# 202.112.8.0/24
# 222.29.0.0/17
# 222.29.128.0/19
# 115.27.0.0/16
# 2001:da8:201::/48
route ${OPS} -net 115.27.0.0/16 ${ROUTE_GW}
route ${OPS} -net 162.105.0.0/16 ${ROUTE_GW}
route ${OPS} -net 202.112.7.0/24 ${ROUTE_GW}
route ${OPS} -net 202.112.8.0/24 ${ROUTE_GW}
route ${OPS} -net 222.29.0.0/17 ${ROUTE_GW}
route ${OPS} -net 222.29.128.0/19 ${ROUTE_GW}
route ${OPS} -A inet6 2001:da8:201::/48 ${ROUTE_GW}
END_TEXT

# 更新 4Share 库 router 目录
/bin/cp -f accelerated-domains.china.conf router
/bin/rm -f china_ip_list.txt china-ipv4.txt china-ipv6.txt
fromdos route.sh
/bin/mv -f route.sh router

# 在已有 accelerated-domains.china.conf 文件的基础上做二次修改，使符合 DNSCrypt 配置格式
sed -i -E -e 's/server=\///g' -e '/^#|^$/d' -e '/Disable/d' -e 's/\//    /g' accelerated-domains.china.conf
sed -i -E 's/223.5.5.5/162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29/g' accelerated-domains.china.conf

# 建立 forwarding-rules.txt 文件
cat > forwarding-rules.txt << 'END_TEXT'
##################################
#        Forwarding rules        #
##################################

## This is used to route specific domain names to specific servers.
## The general format is:
## <domain> <server address>[:port] [, <server address>[:port]...]
## IPv6 addresses can be specified by enclosing the address in square brackets.

## In order to enable this feature, the "forwarding_rules" property needs to
## be set to this file name inside the main configuration file.

## Blocking IPv6 may prevent local devices from being discovered.
## If this happens, set `block_ipv6` to `false` in the main config file.

## Forward *.lan, *.local, *.home, *.internal and *.localdomain to 192.168.1.1
# lan             192.168.1.1
# local           192.168.1.1
# home            192.168.1.1
# internal        192.168.1.1
# localdomain     192.168.1.1

## Forward queries for example.com and *.example.com to 9.9.9.9 and 8.8.8.8
# example.com     9.9.9.9,8.8.8.8

# To generate:
# sed -i -E -e 's/server=\///g' -e '/^#|^$/d' -e '/Disable/d' -e 's/\//    /g' accelerated-domains.china.conf

lan    192.168.50.1
local    192.168.50.1
home    192.168.50.1
internal    192.168.50.1
localdomain    192.168.50.1
workgroup    192.168.50.1
# 10.in-addr.arpa    192.168.50.1
192.in-addr.arpa    192.168.50.1
# 254.169.in-addr.arpa    192.168.50.1
# 16.172.in-addr.arpa    192.168.50.1
# 17.172.in-addr.arpa    192.168.50.1
# 18.172.in-addr.arpa    192.168.50.1
# 19.172.in-addr.arpa    192.168.50.1
# 20.172.in-addr.arpa    192.168.50.1
# 21.172.in-addr.arpa    192.168.50.1
# 22.172.in-addr.arpa    192.168.50.1
# 23.172.in-addr.arpa    192.168.50.1
# 24.172.in-addr.arpa    192.168.50.1
# 25.172.in-addr.arpa    192.168.50.1
# 26.172.in-addr.arpa    192.168.50.1
# 27.172.in-addr.arpa    192.168.50.1
# 28.172.in-addr.arpa    192.168.50.1
# 29.172.in-addr.arpa    192.168.50.1
# 30.172.in-addr.arpa    192.168.50.1
# 31.172.in-addr.arpa    192.168.50.1

altmetric.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
apabi.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
clarivate.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
doi.org    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
els-cdn.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
elsevier-ae.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
elsevier.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
evise.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
japanknowledge.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
jbe-platform.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
jstor.org    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
literatumonline.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
mywconline.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
oup.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
pkuhelper.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
pnas.org    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
proquest.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
researchgate.net    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
rgstatic.net    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
sciencedirect.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
sciencedirectassets.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
scopus.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
serialssolutions.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
silverchair-cdn.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
springer.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
springernature.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
tandfonline.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
thomsonreuters.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
tuna.moe    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
webofknowledge.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
webofscience.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
wiley.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
wkap.nl    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353

npupt.com    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
byr.cn    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
pku.edu.cn    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
edu.cn    162.105.129.122,162.105.129.88,162.105.129.27,162.105.129.26,101.6.6.6:5353
ac.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
com.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
org.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
net.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
gov.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
mil.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
ah.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
bj.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
cq.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
fj.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
gd.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
gs.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
gz.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
gx.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
ha.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
hb.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
he.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
hi.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
hl.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
hn.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
jl.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
js.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
jx.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
ln.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
nm.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
nx.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
qh.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
sc.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
sd.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
sh.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
sn.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
sx.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
tj.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
yn.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
zj.cn    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
xn--fiqs8s    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29
xn--fiqz9s    162.105.129.122,162.105.129.88,101.6.6.6:5353,223.5.5.5,119.29.29.29

END_TEXT

cat accelerated-domains.china.conf >> forwarding-rules.txt

# 更新 4Share 库 DNSCrypt 目录
/bin/rm -f accelerated-domains.china.conf
fromdos forwarding-rules.txt
/bin/mv -f forwarding-rules.txt DNSCrypt

# 推送更新到 GitHub
git add -- *
git commit -a -m "Auto Commit"
git push
