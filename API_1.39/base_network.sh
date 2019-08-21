#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

# USAGE
if [ "$#" -ne 2 ]; then
  echo "# info of specific networks [remote_addr] [network_name_or_id]"
  echo "$0 192.168.70.27:2736 bridge"
  exit -1
fi

API_VERSION=v1.39
ADDR=$1
NAME_OR_ID=$2

# RUN command
curl -s -w "%{size_download}\n%{http_code}" -X GET "http://${ADDR}/${API_VERSION}/networks?filters=%7B%22name%22%3A%7B%22${NAME_OR_ID}%22%3Atrue%7D%7D" -H "accept: application/json"| {
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
