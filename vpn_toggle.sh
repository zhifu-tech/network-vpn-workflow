#!/bin/bash

IFS=':' read -r _ connected_id _ status id _ name <<< "$1"
echo "$connected_id $status "
# last is connected, do action disconnect!
if [ "$status" == 'Connected' ]; then
  scutil --nc stop "$id"
  echo "$name has stopped!"
else
  # has other connected item, stop it first.
  if [ "$connected_id" != "$id" ]; then
      scutil --nc stop "$connected_id"
      # sleep some time to keep execute order.
      sleep 1
  fi
  scutil --nc start "$id"
  echo "$name is connected!"
fi