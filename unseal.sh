#!/bin/sh -x

KEYS=keys
NODES="https://vault1.example.com:8200 https://vault2.example.com:8200 https://vault3.example.com:8200"

for k in $(cat $KEYS | grep -i unseal | cut -d: -f 2 | sed 's/ //g'); do
  for node in $NODES; do
    curl --insecure -X POST --data "{\"key\":\"$k\"}" $node/v1/sys/unseal 
  done
done
