#!/bin/bash

# 放弃所有本地修改，强制与 GitHub 源进行同步
cd /github/4Share
git fetch --all
git reset --hard origin/master

# 清理当前目录下所有将由脚本更新的文件，确保不会保留任何旧文件
rm route.sh china_ip_list.txt ip_list_?.txt accelerated-domains.china.conf
rm */route.sh */china_ip_list.txt */ip_list_?.txt */accelerated-domains.china.conf

# 下载最新文件
timeout 20s wget https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt
timeout 20s wget https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf

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
mv ip_list_?.txt Proxifier -f

# 通过 sed 命令处理之
sed -i 's/114.114.114.114/162.105.129.27/g' accelerated-domains.china.conf
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
# wget https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt
# sed -i -e 's/^/route\ \${OPS}\ -net\ &/g' -e 's/$/&\ \${ROUTE_GW}/g' china_ip_list.txt

# 另一边要用到的命令：
# wget https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
# sed -i 's/114.114.114.114/162.105.129.27/g' accelerated-domains.china.conf

END_TEXT

cat china_ip_list.txt >> route.sh << 'END_TEXT'
END_TEXT

cat >> route.sh << 'END_TEXT'


# https://its.pku.edu.cn/faq_2.jsp  --获得北大IP网段
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
cp accelerated-domains.china.conf router -f
rm china_ip_list.txt
mv route.sh router -f

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

pku.edu.cn    162.105.129.27
END_TEXT

cat accelerated-domains.china.conf >> forwarding-rules.txt << 'END_TEXT'
END_TEXT

# 更新 4Share 库 DNSCrypt 目录
rm accelerated-domains.china.conf
mv forwarding-rules.txt DNSCrypt -f

# 推送更新到 GitHub
git add *
git commit -a -m "Auto Commit"
git push
