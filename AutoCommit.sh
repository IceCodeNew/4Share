#!/bin/bash

# 放弃所有本地修改，强制与 GitHub 源进行同步
cd /github/4Share
git fetch --all
git reset --hard origin/master

# 清理当前目录下所有将由脚本更新的文件，确保不会保留任何旧文件
rm -f route.sh china_ip_list.txt ip_list_?.txt accelerated-domains.china.conf
rm -f */route.sh */china_ip_list.txt */ip_list_?.txt */accelerated-domains.china.conf

# 下载最新文件
timeout 20s wget -qo- https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt
timeout 20s wget -qo- https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf

# 针对北京大学校园网划分网段进行特殊处理
sed -i '/.*115\.27\.0\.0.*/'d china_ip_list.txt
sed -i '/.*162\.105\.0\.0.*/'d china_ip_list.txt
sed -i '/.*202\.112\.7\.0.*/'d china_ip_list.txt
sed -i '/.*202\.112\.8\.0.*/'d china_ip_list.txt
sed -i '/.*222\.29\.0\.0.*/'d china_ip_list.txt
sed -i '/.*222\.29\.128\.0.*/'d china_ip_list.txt

# 创建用于写入 Proxifier 规则的 IP 白名单列表
# 1. Proxifier 规则暂不支持 CIDR 格式的 IP 地址，因此需要做格式上的转换
# 2. Proxifier 一条规则内最大能写入 32767 个字符，远远小于格式转换后的 IP 列表字符长，
#    因此需要将 china_ip_list 拆分为多个规则。
python3 Proxifier/IPConvert.py
mv -f ip_list_?.txt Proxifier

# 通过 sed 命令处理之
sed -i 's/114.114.114.114/223.5.5.5/g' accelerated-domains.china.conf
sed -i '/^#/d' accelerated-domains.china.conf
sed -i -e 's/^/route\ \${OPS}\ -net\ &/g' -e 's/$/&\ \${ROUTE_GW}/g' china_ip_list.txt

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

cat china_ip_list.txt >> route.sh << 'END_TEXT'
END_TEXT

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
cp -f accelerated-domains.china.conf router
rm -f china_ip_list.txt
mv -f route.sh router

# 在已有 accelerated-domains.china.conf 文件的基础上做二次修改，使符合 DNSCrypt 配置格式
sed -i -e 's/server=\///g' -e 's/\//    /g' accelerated-domains.china.conf
# 这条语句目前来说没有作用，仅留作备用。
# sed -i '/\.cn\s\{4\}/'d accelerated-domains.china.conf

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

google.com    115.27.254.4
google.ad    115.27.254.4
google.ae    115.27.254.4
google.com.af    115.27.254.4
google.com.ag    115.27.254.4
google.com.ai    115.27.254.4
google.al    115.27.254.4
google.am    115.27.254.4
google.co.ao    115.27.254.4
google.com.ar    115.27.254.4
google.as    115.27.254.4
google.at    115.27.254.4
google.com.au    115.27.254.4
google.az    115.27.254.4
google.ba    115.27.254.4
google.com.bd    115.27.254.4
google.be    115.27.254.4
google.bf    115.27.254.4
google.bg    115.27.254.4
google.com.bh    115.27.254.4
google.bi    115.27.254.4
google.bj    115.27.254.4
google.com.bn    115.27.254.4
google.com.bo    115.27.254.4
google.com.br    115.27.254.4
google.bs    115.27.254.4
google.bt    115.27.254.4
google.co.bw    115.27.254.4
google.by    115.27.254.4
google.com.bz    115.27.254.4
google.ca    115.27.254.4
google.cd    115.27.254.4
google.cf    115.27.254.4
google.cg    115.27.254.4
google.ch    115.27.254.4
google.ci    115.27.254.4
google.co.ck    115.27.254.4
google.cl    115.27.254.4
google.cm    115.27.254.4
google.cn    115.27.254.4
google.com.co    115.27.254.4
google.co.cr    115.27.254.4
google.com.cu    115.27.254.4
google.cv    115.27.254.4
google.com.cy    115.27.254.4
google.cz    115.27.254.4
google.de    115.27.254.4
google.dj    115.27.254.4
google.dk    115.27.254.4
google.dm    115.27.254.4
google.com.do    115.27.254.4
google.dz    115.27.254.4
google.com.ec    115.27.254.4
google.ee    115.27.254.4
google.com.eg    115.27.254.4
google.es    115.27.254.4
google.com.et    115.27.254.4
google.fi    115.27.254.4
google.com.fj    115.27.254.4
google.fm    115.27.254.4
google.fr    115.27.254.4
google.ga    115.27.254.4
google.ge    115.27.254.4
google.gg    115.27.254.4
google.com.gh    115.27.254.4
google.com.gi    115.27.254.4
google.gl    115.27.254.4
google.gm    115.27.254.4
google.gp    115.27.254.4
google.gr    115.27.254.4
google.com.gt    115.27.254.4
google.gy    115.27.254.4
google.com.hk    115.27.254.4
google.hn    115.27.254.4
google.hr    115.27.254.4
google.ht    115.27.254.4
google.hu    115.27.254.4
google.co.id    115.27.254.4
google.ie    115.27.254.4
google.co.il    115.27.254.4
google.im    115.27.254.4
google.co.in    115.27.254.4
google.iq    115.27.254.4
google.is    115.27.254.4
google.it    115.27.254.4
google.je    115.27.254.4
google.com.jm    115.27.254.4
google.jo    115.27.254.4
google.co.jp    115.27.254.4
google.co.ke    115.27.254.4
google.com.kh    115.27.254.4
google.ki    115.27.254.4
google.kg    115.27.254.4
google.co.kr    115.27.254.4
google.com.kw    115.27.254.4
google.kz    115.27.254.4
google.la    115.27.254.4
google.com.lb    115.27.254.4
google.li    115.27.254.4
google.lk    115.27.254.4
google.co.ls    115.27.254.4
google.lt    115.27.254.4
google.lu    115.27.254.4
google.lv    115.27.254.4
google.com.ly    115.27.254.4
google.co.ma    115.27.254.4
google.md    115.27.254.4
google.me    115.27.254.4
google.mg    115.27.254.4
google.mk    115.27.254.4
google.ml    115.27.254.4
google.com.mm    115.27.254.4
google.mn    115.27.254.4
google.ms    115.27.254.4
google.com.mt    115.27.254.4
google.mu    115.27.254.4
google.mv    115.27.254.4
google.mw    115.27.254.4
google.com.mx    115.27.254.4
google.com.my    115.27.254.4
google.co.mz    115.27.254.4
google.com.na    115.27.254.4
google.com.nf    115.27.254.4
google.com.ng    115.27.254.4
google.com.ni    115.27.254.4
google.ne    115.27.254.4
google.nl    115.27.254.4
google.no    115.27.254.4
google.com.np    115.27.254.4
google.nr    115.27.254.4
google.nu    115.27.254.4
google.co.nz    115.27.254.4
google.com.om    115.27.254.4
google.com.pa    115.27.254.4
google.com.pe    115.27.254.4
google.com.pg    115.27.254.4
google.com.ph    115.27.254.4
google.com.pk    115.27.254.4
google.pl    115.27.254.4
google.pn    115.27.254.4
google.com.pr    115.27.254.4
google.ps    115.27.254.4
google.pt    115.27.254.4
google.com.py    115.27.254.4
google.com.qa    115.27.254.4
google.ro    115.27.254.4
google.ru    115.27.254.4
google.rw    115.27.254.4
google.com.sa    115.27.254.4
google.com.sb    115.27.254.4
google.sc    115.27.254.4
google.se    115.27.254.4
google.com.sg    115.27.254.4
google.sh    115.27.254.4
google.si    115.27.254.4
google.sk    115.27.254.4
google.com.sl    115.27.254.4
google.sn    115.27.254.4
google.so    115.27.254.4
google.sm    115.27.254.4
google.sr    115.27.254.4
google.st    115.27.254.4
google.com.sv    115.27.254.4
google.td    115.27.254.4
google.tg    115.27.254.4
google.co.th    115.27.254.4
google.com.tj    115.27.254.4
google.tk    115.27.254.4
google.tl    115.27.254.4
google.tm    115.27.254.4
google.tn    115.27.254.4
google.to    115.27.254.4
google.com.tr    115.27.254.4
google.tt    115.27.254.4
google.com.tw    115.27.254.4
google.co.tz    115.27.254.4
google.com.ua    115.27.254.4
google.co.ug    115.27.254.4
google.co.uk    115.27.254.4
google.com.uy    115.27.254.4
google.co.uz    115.27.254.4
google.com.vc    115.27.254.4
google.co.ve    115.27.254.4
google.vg    115.27.254.4
google.co.vi    115.27.254.4
google.com.vn    115.27.254.4
google.vu    115.27.254.4
google.ws    115.27.254.4
google.rs    115.27.254.4
google.co.za    115.27.254.4
google.co.zm    115.27.254.4
google.co.zw    115.27.254.4
google.cat    115.27.254.4
youtube.com    115.27.254.4
youtu.be    115.27.254.4
facebook.com    115.27.254.4

byr.cn    115.27.254.4
pku.edu.cn    115.27.254.4
edu.cn    115.27.254.4
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
END_TEXT

cat accelerated-domains.china.conf >> forwarding-rules.txt << 'END_TEXT'
END_TEXT

# 更新 4Share 库 DNSCrypt 目录
rm -f accelerated-domains.china.conf
mv -f forwarding-rules.txt DNSCrypt

# 推送更新到 GitHub
git add *
git commit -a -m "Auto Commit"
git push

