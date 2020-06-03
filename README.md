## 关于 Asus 路由器智能分流和 DNSCrypt 解析加速的一个小轮子以及其他很多很多……  

对大家最有用的东西可能就是`AutoCommit.sh`这个脚本了，这个脚本自动化了以下操作：  

0. 合并两个基于 BGP/ASN 数据的中国运营商 IP 地址库，每日更新`geoip_china/china_ip_list.txt`文件。
1. 基于更新的`geoip_china/china_ip_list.txt`文件，以之为基础批量建立 route 命令，用于在路由器系统上添加路由表（实现智能分流）。
<!-- 2. 下载最新的`accelerated-domains.china.conf`文件，并修改原版文件中配置的 114DNS 为腾讯 Public+ DNS （个人不喜欢 114DNS，等 AliDNS 也支持 EDNS 了我就换成 223.5.5.5 ） -->
2. 下载最新的`accelerated-domains.china.conf`文件，并修改原版文件中配置的 114DNS 为 AliDNS （再也不迷信 EDNS 了 ww）。
3. 以修改后的`accelerated-domains.china.conf`文件为基础建立`forwarding-rules.txt`文件，实现 DNSCrypt 对国内域名解析加速（同时避免解析到海外 CDN 资源上去）。
  
## 本项目基于以下项目，感谢他们的工作使互联网变得更美好！（排名不分先后）  
### https://github.com/felixonmars/dnsmasq-china-list  
#### // Chinese-specific configuration to improve your favorite DNS server.  
  
### https://github.com/jedisct1/dnscrypt-proxy  
#### // A flexible DNS proxy, with support for modern encrypted DNS protocols such as DNSCrypt v2 and DNS-over-HTTPS.  
  
### https://github.com/17mon/china_ip_list 
#### // IPList for China by IPIP.NET

### https://github.com/gaoyifan/china-operator-ip/tree/ip-lists
#### // 中国运营商IPv4/IPv6地址库-每日更新
