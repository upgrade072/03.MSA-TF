#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

API_VERSION=v1.39
ADDR=$1
ID_OR_NAME=$2

# USAGE
if [ "$#" -ne 2 ]; then
  echo "# container start [remote_addr id_or_name]"
  echo "$0 192.168.70.27:2736 LB1_IXPC_0.1"
  exit -1
fi

# RUN command
curl -s -w "%{size_download}\n%{http_code}" -X POST "http://${ADDR}/${API_VERSION}/containers/${ID_OR_NAME}/start" -H "accept: application/json" | {
  read -r body;
  read -r len;
  read -r code;
  if [ "$body" = "0" ]; then
      body="{\"body\":null}"
      code=$len
  fi;
  echo $body | jq;
  exit $code;
}

# RETURN http status code
RES=$?;
exit $RES;
