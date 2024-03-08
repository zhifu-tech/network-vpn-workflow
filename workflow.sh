#!/bin/bash

source 'vpns.sh'
source 'pings.sh'

declare -a items=()

# load vpn items
declare -a vpn_items=()
vpn_load_items

# load ping time
ping_load_data

vpn_ids=""
vpn_connected_id="$(vpn_connected_item_id)"
# associate ping data with vpn items
for i in "${!vpn_items[@]}" ; do
  vpn_item="${vpn_items[i]}"
  vpn_item_id=$(vpn_item_id "$vpn_item")
  ping_time=$(ping_find_ping_time "$vpn_item_id")
  vpn_items[i]="VPN:$vpn_connected_id:$ping_time:$vpn_item"
  if [ "$i" -ne 0 ]; then
    vpn_ids+=","
  fi
  vpn_ids+="$vpn_item_id"
done

# load ping item
IFS= read -r ping_item <<< "$(ping_load_item)"
ping_item="PING:$vpn_ids:$ping_item"

# insert ping item after connected item, or first.
if [ -n "$vpn_connected_id" ]; then
  if [ "${#vpn_items[@]}" -ge 3 ]; then
    part1=("${vpn_items[@]:0:3}")
    part2=("${vpn_items[@]:3}")
    items=("${part1[@]}" "$ping_item" "${part2[@]}")
  else
    items=("${vpn_items[@]}" "$ping_item")
  fi
else
  items=("$ping_item" "${vpn_items[@]}")
fi

# assemble vpn list to workflow format.
wf_items="{\"items\":["
need_comma=0

declare title=""
declare subtitle=""
declare icon_path=""
# config vpn toggle items
for item in "${items[@]}" ; do
  IFS=':' read -r flag raw_item <<< "$item"
  if [[ "$flag" == "VPN" ]]; then
    IFS=':' read -r _ ping_time vpn_item <<< "$raw_item"
    vpn_to_workflow_item "$vpn_item" "$ping_time"
  elif [[ "$flag" == "PING" ]]; then
    ping_to_workflow_item "$raw_item"
  else
    continue
  fi
  if [ "$need_comma" == 1 ]; then
    wf_items+=','
  else
    need_comma=1
  fi
  wf_items+="{\"title\":\"$title\",\"subtitle\":\"$subtitle\",\"arg\":\"$item\",\"icon\":{\"path\":\"$icon_path\"}}"
done

wf_items+="]}"

# output the workflow format data
echo "$wf_items"