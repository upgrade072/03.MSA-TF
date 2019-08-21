#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

# USAGE
if [ "$#" -ne 1 ]; then
  echo "# list all of images [remote_addr]"
  echo "$0 192.168.70.27:2736 "
  exit -1
fi

API_VERSION=v1.39
ADDR=$1

# RUN command
curl -s -w "%{size_download}\n%{http_code}" -X GET "http://${ADDR}/${API_VERSION}/images/json?all=false&digests=false" -H "accept: application/json"| {
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
