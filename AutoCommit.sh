#!/bin/bash

REPOS_ROOT='/github'

cd "$REPOS_ROOT/4Share/" || exit
# 清理当前目录下所有将由脚本更新的文件，确保不会保留任何旧文件
find . -type f -iname route.sh -print0 | xargs -0 rm --
find . -type f -iname china_ip_list.txt -print0 | xargs -0 rm --
find . -type f -iname china-ipv6.txt -print0 | xargs -0 rm --
find . -type f -iregex ".*ip_list_.?.txt" -print0 | xargs -0 rm --
find . -type f -iname accelerated-domains.china.conf -print0 | xargs -0 rm --

# 拷贝最新文件
/bin/cp -f "$REPOS_ROOT/dnsmasq-china-list/accelerated-domains.china.conf" ./
/bin/cp -f "$REPOS_ROOT/china_ip_list/china_ip_list.txt" ./
/bin/mv -f "$REPOS_ROOT/china-ipv6.txt" ./
fromdos china_ip_list.txt china-ipv6.txt accelerated-domains.china.conf

# 针对北京大学校园网划分网段进行特殊处理
sed -i -E '/^115\.27\.0\.0.*/d' china_ip_list.txt
sed -i -E '/^162\.105\.0\.0.*/d' china_ip_list.txt
sed -i -E '/^202\.112\.7\.0.*/d' china_ip_list.txt
sed -i -E '/^202\.112\.8\.0.*/d' china_ip_list.txt
sed -i -E '/^222\.29\.0\.0.*/d' china_ip_list.txt
sed -i -E '/^222\.29\.128\.0.*/d' china_ip_list.txt
sed -i -E '/^2001:da8:201::.*/d' china-ipv6.txt

# 创建用于写入 Proxifier 规则的 IP 白名单列表
# 1. Proxifier 规则暂不支持 CIDR 格式的 IP 地址，因此需要做格式上的转换
# 2. Proxifier 一条规则内最大能写入 32767 个字符，远远小于格式转换后的 IP 列表字符长，
#    因此需要将 china_ip_list 拆分为多个规则。
fromdos Proxifier/IPConvert.py Proxifier/IPv6Convert.py
python3 Proxifier/IPConvert.py
python3 Proxifier/IPv6Convert.py
/bin/mv -f ip_list_?.txt ipv6_list_?.txt Proxifier

# 通过 sed 命令处理之
sed -i 's/114.114.114.114/223.5.5.5/g' accelerated-domains.china.conf
sed -i '/^#/d' accelerated-domains.china.conf
sed -i '/^server=\/tsdm/d' accelerated-domains.china.conf
sed -i -e "s/^/route\ \${OPS}\ -net\ &/g" -e "s/$/&\ \${ROUTE_GW}/g" china_ip_list.txt

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
# sed -i -e 's/^/route\ \${OPS}\ -net\ &/g' -e 's/$/&\ \${ROUTE_GW}/g' china_ip_list.txt

# 另一边要用到的命令：
# wget -qo- https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
# sed -i 's/114.114.114.114/223.5.5.5/g' accelerated-domains.china.conf

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
/bin/rm -f china_ip_list.txt china-ipv6.txt
fromdos route.sh
/bin/mv -f route.sh router

# 在已有 accelerated-domains.china.conf 文件的基础上做二次修改，使符合 DNSCrypt 配置格式
sed -i -e 's/server=\///g' -e 's/\//    /g' accelerated-domains.china.conf

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

## Forward queries for example.com and *.example.com to 9.9.9.9 and 8.8.8.8
# example.com     9.9.9.9,8.8.8.8

# To generate:
# sed -i -e 's/server=\///g' -e 's/\//    /g' accelerated-domains.china.conf

# lan    192.168.50.1
# 10.in-addr.arpa    192.168.50.1
# 192.in-addr.arpa    192.168.50.1
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

# google.com    162.105.129.122
# google.ad    162.105.129.122
# google.ae    162.105.129.122
# google.com.af    162.105.129.122
# google.com.ag    162.105.129.122
# google.com.ai    162.105.129.122
# google.al    162.105.129.122
# google.am    162.105.129.122
# google.co.ao    162.105.129.122
# google.com.ar    162.105.129.122
# google.as    162.105.129.122
# google.at    162.105.129.122
# google.com.au    162.105.129.122
# google.az    162.105.129.122
# google.ba    162.105.129.122
# google.com.bd    162.105.129.122
# google.be    162.105.129.122
# google.bf    162.105.129.122
# google.bg    162.105.129.122
# google.com.bh    162.105.129.122
# google.bi    162.105.129.122
# google.bj    162.105.129.122
# google.com.bn    162.105.129.122
# google.com.bo    162.105.129.122
# google.com.br    162.105.129.122
# google.bs    162.105.129.122
# google.bt    162.105.129.122
# google.co.bw    162.105.129.122
# google.by    162.105.129.122
# google.com.bz    162.105.129.122
# google.ca    162.105.129.122
# google.cd    162.105.129.122
# google.cf    162.105.129.122
# google.cg    162.105.129.122
# google.ch    162.105.129.122
# google.ci    162.105.129.122
# google.co.ck    162.105.129.122
# google.cl    162.105.129.122
# google.cm    162.105.129.122
# google.cn    162.105.129.122
# google.com.co    162.105.129.122
# google.co.cr    162.105.129.122
# google.com.cu    162.105.129.122
# google.cv    162.105.129.122
# google.com.cy    162.105.129.122
# google.cz    162.105.129.122
# google.de    162.105.129.122
# google.dj    162.105.129.122
# google.dk    162.105.129.122
# google.dm    162.105.129.122
# google.com.do    162.105.129.122
# google.dz    162.105.129.122
# google.com.ec    162.105.129.122
# google.ee    162.105.129.122
# google.com.eg    162.105.129.122
# google.es    162.105.129.122
# google.com.et    162.105.129.122
# google.fi    162.105.129.122
# google.com.fj    162.105.129.122
# google.fm    162.105.129.122
# google.fr    162.105.129.122
# google.ga    162.105.129.122
# google.ge    162.105.129.122
# google.gg    162.105.129.122
# google.com.gh    162.105.129.122
# google.com.gi    162.105.129.122
# google.gl    162.105.129.122
# google.gm    162.105.129.122
# google.gp    162.105.129.122
# google.gr    162.105.129.122
# google.com.gt    162.105.129.122
# google.gy    162.105.129.122
# google.com.hk    162.105.129.122
# google.hn    162.105.129.122
# google.hr    162.105.129.122
# google.ht    162.105.129.122
# google.hu    162.105.129.122
# google.co.id    162.105.129.122
# google.ie    162.105.129.122
# google.co.il    162.105.129.122
# google.im    162.105.129.122
# google.co.in    162.105.129.122
# google.iq    162.105.129.122
# google.is    162.105.129.122
# google.it    162.105.129.122
# google.je    162.105.129.122
# google.com.jm    162.105.129.122
# google.jo    162.105.129.122
# google.co.jp    162.105.129.122
# google.co.ke    162.105.129.122
# google.com.kh    162.105.129.122
# google.ki    162.105.129.122
# google.kg    162.105.129.122
# google.co.kr    162.105.129.122
# google.com.kw    162.105.129.122
# google.kz    162.105.129.122
# google.la    162.105.129.122
# google.com.lb    162.105.129.122
# google.li    162.105.129.122
# google.lk    162.105.129.122
# google.co.ls    162.105.129.122
# google.lt    162.105.129.122
# google.lu    162.105.129.122
# google.lv    162.105.129.122
# google.com.ly    162.105.129.122
# google.co.ma    162.105.129.122
# google.md    162.105.129.122
# google.me    162.105.129.122
# google.mg    162.105.129.122
# google.mk    162.105.129.122
# google.ml    162.105.129.122
# google.com.mm    162.105.129.122
# google.mn    162.105.129.122
# google.ms    162.105.129.122
# google.com.mt    162.105.129.122
# google.mu    162.105.129.122
# google.mv    162.105.129.122
# google.mw    162.105.129.122
# google.com.mx    162.105.129.122
# google.com.my    162.105.129.122
# google.co.mz    162.105.129.122
# google.com.na    162.105.129.122
# google.com.nf    162.105.129.122
# google.com.ng    162.105.129.122
# google.com.ni    162.105.129.122
# google.ne    162.105.129.122
# google.nl    162.105.129.122
# google.no    162.105.129.122
# google.com.np    162.105.129.122
# google.nr    162.105.129.122
# google.nu    162.105.129.122
# google.co.nz    162.105.129.122
# google.com.om    162.105.129.122
# google.com.pa    162.105.129.122
# google.com.pe    162.105.129.122
# google.com.pg    162.105.129.122
# google.com.ph    162.105.129.122
# google.com.pk    162.105.129.122
# google.pl    162.105.129.122
# google.pn    162.105.129.122
# google.com.pr    162.105.129.122
# google.ps    162.105.129.122
# google.pt    162.105.129.122
# google.com.py    162.105.129.122
# google.com.qa    162.105.129.122
# google.ro    162.105.129.122
# google.ru    162.105.129.122
# google.rw    162.105.129.122
# google.com.sa    162.105.129.122
# google.com.sb    162.105.129.122
# google.sc    162.105.129.122
# google.se    162.105.129.122
# google.com.sg    162.105.129.122
# google.sh    162.105.129.122
# google.si    162.105.129.122
# google.sk    162.105.129.122
# google.com.sl    162.105.129.122
# google.sn    162.105.129.122
# google.so    162.105.129.122
# google.sm    162.105.129.122
# google.sr    162.105.129.122
# google.st    162.105.129.122
# google.com.sv    162.105.129.122
# google.td    162.105.129.122
# google.tg    162.105.129.122
# google.co.th    162.105.129.122
# google.com.tj    162.105.129.122
# google.tk    162.105.129.122
# google.tl    162.105.129.122
# google.tm    162.105.129.122
# google.tn    162.105.129.122
# google.to    162.105.129.122
# google.com.tr    162.105.129.122
# google.tt    162.105.129.122
# google.com.tw    162.105.129.122
# google.co.tz    162.105.129.122
# google.com.ua    162.105.129.122
# google.co.ug    162.105.129.122
# google.co.uk    162.105.129.122
# google.com.uy    162.105.129.122
# google.co.uz    162.105.129.122
# google.com.vc    162.105.129.122
# google.co.ve    162.105.129.122
# google.vg    162.105.129.122
# google.co.vi    162.105.129.122
# google.com.vn    162.105.129.122
# google.vu    162.105.129.122
# google.ws    162.105.129.122
# google.rs    162.105.129.122
# google.co.za    162.105.129.122
# google.co.zm    162.105.129.122
# google.co.zw    162.105.129.122
# google.cat    162.105.129.122
# youtube.com    162.105.129.122
# youtu.be    162.105.129.122
# facebook.com    162.105.129.122

altmetric.com    162.105.129.122
apabi.com    162.105.129.122
clarivate.com    162.105.129.122
doi.org    162.105.129.122
els-cdn.com    162.105.129.122
elsevier-ae.com    162.105.129.122
elsevier.com    162.105.129.122
evise.com    162.105.129.122
japanknowledge.com    162.105.129.122
jbe-platform.com    162.105.129.122
jstor.org    162.105.129.122
literatumonline.com    162.105.129.122
mywconline.com    162.105.129.122
oup.com    162.105.129.122
pkuhelper.com    162.105.129.122
pnas.org    162.105.129.122
proquest.com    162.105.129.122
researchgate.net    162.105.129.122
rgstatic.net    162.105.129.122
sciencedirect.com    162.105.129.122
sciencedirectassets.com    162.105.129.122
scopus.com    162.105.129.122
serialssolutions.com    162.105.129.122
silverchair-cdn.com    162.105.129.122
springer.com    162.105.129.122
springernature.com    162.105.129.122
tandfonline.com    162.105.129.122
thomsonreuters.com    162.105.129.122
tuna.moe    162.105.129.122
webofknowledge.com    162.105.129.122
webofscience.com    162.105.129.122
wiley.com    162.105.129.122
wkap.nl    162.105.129.122

npupt.com    162.105.129.122
byr.cn    162.105.129.122
pku.edu.cn    162.105.129.122
edu.cn    162.105.129.122
ac.cn    223.5.5.5
com.cn    223.5.5.5
org.cn    223.5.5.5
net.cn    223.5.5.5
gov.cn    223.5.5.5
mil.cn    223.5.5.5
cn    223.5.5.5
ah.cn    223.5.5.5
bj.cn    223.5.5.5
cq.cn    223.5.5.5
fj.cn    223.5.5.5
gd.cn    223.5.5.5
gs.cn    223.5.5.5
gz.cn    223.5.5.5
gx.cn    223.5.5.5
ha.cn    223.5.5.5
hb.cn    223.5.5.5
he.cn    223.5.5.5
hi.cn    223.5.5.5
hl.cn    223.5.5.5
hn.cn    223.5.5.5
jl.cn    223.5.5.5
js.cn    223.5.5.5
jx.cn    223.5.5.5
ln.cn    223.5.5.5
nm.cn    223.5.5.5
nx.cn    223.5.5.5
qh.cn    223.5.5.5
sc.cn    223.5.5.5
sd.cn    223.5.5.5
sh.cn    223.5.5.5
sn.cn    223.5.5.5
sx.cn    223.5.5.5
tj.cn    223.5.5.5
yn.cn    223.5.5.5
zj.cn    223.5.5.5
xn--fiqs8s    223.5.5.5
xn--fiqz9s    223.5.5.5

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
