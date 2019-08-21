#!/bin/bash

# USAGE
if [ "$#" -ne 2 ]; then
  echo "# info of connected network [remote_addr] [id_or_name]"
  echo "$0 192.168.70.27:2736 LB1_IXPC_0.1"
  exit -1
fi

BODY=$(./base_inspect.sh $@)
RES=$?

echo $BODY | jq .NetworkSettings.Networks
exit $RES
~             
