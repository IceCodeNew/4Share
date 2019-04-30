#!/bin/bash

REPOS_ROOT='/github'

# 检查上游是否有更新
cd "$REPOS_ROOT/dnsmasq-china-list"
git fetch --all > /dev/null 2>&1
git status | grep "Your branch is up to date with 'origin/master'." > /dev/null 2>&1
stat_dnsmasq=$?
# 将 HEAD 指向上游更新
git reset --hard origin/master

cd "$REPOS_ROOT/china_ip_list"
git fetch --all > /dev/null 2>&1
git status | grep "Your branch is up to date with 'origin/master'." > /dev/null 2>&1
stat_chinaip=$?
git reset --hard origin/master

if [ $stat_dnsmasq -ne 0 -o $stat_chinaip -ne 0 ]; then
    bash AutoCommit.sh
else
    exit 0
fi
