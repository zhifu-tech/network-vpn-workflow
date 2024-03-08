#!/bin/bash

vpn_load_items() {
  # read vpn list
  # define a tmp file to store vpn list.
  tmp_file=$(mktemp)
  scutil --nc list | grep "VPN" > "$tmp_file"

  while IFS= read -r vpn; do
    status_regex='\(([^)]+)\)'
    if [[ $vpn =~ $status_regex ]]; then
      status="${BASH_REMATCH[1]}"
    else continue
    fi
    id_regex='([0-9A-Fa-f-]{36})'
    if [[ $vpn =~ $id_regex ]]; then
      id="${BASH_REMATCH[1]}"
    else continue
    fi
    supplier_regex='VPN \(([^)]+)\)'
    if [[ $vpn =~ $supplier_regex ]]; then
      supplier="${BASH_REMATCH[1]}"
    else continue
    fi
    name_regex='"([^"]+)"'
    if [[ $vpn =~ $name_regex ]]; then
      name="${BASH_REMATCH[1]}"
    else continue
    fi

    vpn_items+=("$status:$id:$supplier:$name")
  done < "$tmp_file"

  # remove tmp_file
  rm "$tmp_file"

  # move the connected item to the first place.
  for i in "${!vpn_items[@]}" ; do
    vpn_item=${vpn_items[i]}
    status=$(vpn_item_status "$vpn_item")
    if [[ "$status" == 'Connected' ]]; then
      if [ "$i" -ne 0 ]; then
        tmp_item=${vpn_items[0]}
        vpn_items[0]=$vpn_item
        vpn_items[i]=$tmp_item
      fi
      break
    fi
  done
}

vpn_item_id() {
  vpn_item=$1
  IFS=':' read -r _ id _ <<< "$vpn_item"
  echo "$id"
}

vpn_item_status() {
  vpn_item=$1
  IFS=':' read -r status _ _ _ <<< "$vpn_item"
  echo "$status"
}

vpn_connected_item_id() {
  vpn_item=${vpn_items[0]}
  IFS=':' read -r status id _ _ <<< "$vpn_item"
  [ "$status" == 'Connected' ] && echo "$id" || echo ""
}

vpn_to_workflow_item() {
  vpn_item=$1
  pine_time=$2
  IFS=':' read -r status id supplier name <<< "$vpn_item"
  export title=$name
  export subtitle="$pine_time, $status, $supplier"
  if [ "$status" == 'Connected' ]; then
    export icon_path="./icon-on.svg"
  else
    export icon_path="./icon-off.svg"
  fi
}
