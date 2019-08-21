#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

# USAGE
if [ "$#" -ne 2 ]; then
  echo "# info of specific images [remote_addr] [repo:tag]"
  echo "$0 192.168.70.27:2736 ixpc:0.1"
  exit -1
fi

API_VERSION=v1.39
ADDR=$1
NAME=$2

# RUN command
curl -s -w "%{size_download}\n%{http_code}" -X GET "http://${ADDR}/${API_VERSION}/images/${NAME}/json" -H "accept: application/json"| {
  read -r body;
  read -r len;
  read -r code;
  if [ "$body" = "0" ]; then
      body="{\"body\":null}"
      code=$len
  fi;
  echo $body;
  exit $code;
}

# RETURN http status code
RES=$?;
exit $RES;
