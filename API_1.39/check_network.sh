#!/bin/bash

# USAGE
if [ "$#" -ne 2 ]; then
  echo "# check specific network [remote_addr] [network_id_or_name]"
  echo "$0 192.168.70.27:2736 lb1_http_inner"
  exit -1
fi

BODY=$(./base_network.sh $@)
RES=$?

echo $BODY | jq .
exit $RES
