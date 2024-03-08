#!/bin/bash

IFS=':' read -r _ vpn_ids_string _ <<< "$1"
IFS=',' read -r -a vpn_ids <<< "$vpn_ids_string"

# 文件不存在，创建文件；否则，清空文件
if [ ! -f "ping_data.txt" ]; then
  touch "ping_data.txt"
else
  echo "" > "ping_data.txt"
fi

source 'pings.sh'
for vpn_id in "${vpn_ids[@]}" ; do
  ping_execute "$vpn_id" &
done