#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

# USAGE
if [ "$#" -ne 2 ]; then
  echo "# delete specific network [addr] [net_name]"
  echo "$0 192.168.70.27:2736 lb1_http_inner"
  exit -1
fi

API_VERSION=v1.39
ADDR=$1
NET_NAME=$2

# RUN command
curl -s -w "%{size_download}\n%{http_code}" -X DELETE "http://${ADDR}/${API_VERSION}/networks/${NET_NAME}" -H "accept: application/json" -H "Content-Type: application/json" -d "${BODY}" | {
  read -r body;
  read -r len;
  read -r code;
  if [ "$body" = "0" ]; then
      body="{\"body\":null}"
      code=$len
  fi; 
  echo $body | jq .;
  exit $code;
}

# RETURN http status code
RES=$?;
exit $RES;
