#!/bin/bash

# USAGE
if [ "$#" -ne 2 ]; then
  echo "# info of specific images [remote_addr] [repo:tag]"
  echo "$0 192.168.70.27:2736 ixpc:0.1"
  exit -1
fi

BODY=$(./base_image.sh $@)
RES=$?

echo $BODY | jq .Config
exit $RES
