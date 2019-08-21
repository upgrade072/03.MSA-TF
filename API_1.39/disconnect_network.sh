#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

# USAGE
if [ "$#" -ne 3 ]; then
  echo "# disconnect network from container [addr] [net_name_or_id] [container_name_or_id]"
  echo "$0 192.168.70.27:2736 lb1_http_inner LB1_HTTPC_0.1"
  exit -1
fi

API_VERSION=v1.39
ADDR=$1
NET_NAME=$2
CONT_NAME=$3

BODY="
{
  \"Container\": \"${CONT_NAME}\",
  \"Force\": true
}"

# RUN command
curl -s -w "%{size_download}\n%{http_code}" -X POST "http://${ADDR}/${API_VERSION}/networks/${NET_NAME}/disconnect" -H "accept: application/json" -H "Content-Type: application/json" -d "${BODY}" | {
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
