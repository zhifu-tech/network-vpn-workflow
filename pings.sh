#!/bin/bash

declare title=""
declare subtitle=""
declare icon_path=""
declare -a ping_data=()

ping_load_item() {
  echo "Ping the vpn list!"
}

ping_load_data() {
  [ ! -f "ping_data.txt" ] && return
  while IFS= read -r line; do
    ping_data+=("$line")
  done< "ping_data.txt"
}

ping_find_ping_time() {
  id=$1
  for data in "${ping_data[@]}" ; do
    IFS=':' read -r ping_id ping_time <<< "$data"
    [ "$ping_id" == "$id" ] && echo "$ping_time ms" && return
  done
  echo "N/A"
}

ping_to_workflow_item() {
  export title="Ping the vpn"
  export subtitle="Ping the vpn"
  export icon_path="icon-ping.svg"
}

ping_execute() {
  vpn_id=$1
  ip_port=$(scutil --nc show "$vpn_id" | grep 'RemoteAddress' | awk '{print $3}' &)
  IFS=':' read -r ip _ <<< "$ip_port"
  echo "$ip_port ip=$ip"
  [ -z "$ip" ] && return
  result=$(ping -c 3 "$ip" | awk -F'=' '/^round-trip/{sum+=$2; count+=1} END {if (count>0) print sum/count}')
  [ -z "$result" ] && return
  echo "$vpn_id:$result" >> "ping_data.txt"
}