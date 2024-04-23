#!/bin/bash

CONFIG_FILE=$1
SCRIPT=$2
data=$3

server_id=0
while IFS= read -r line; do
    host=$line
    ssh -t "$host" "bash -s" < "$SCRIPT" "$data" "$server_id" &
    server_id=$((server_id + 1))
done < "$CONFIG_FILE"
