#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

# USAGE
if [ "$#" -ne 3 ]; then
  echo "# create bridge network [addr] [net_name] [internal only]"
  echo "$0 192.168.70.27:2736 lb1_http_inner true"
  exit -1
fi

API_VERSION=v1.39
ADDR=$1
NET_NAME=$2
INTERNAL=$3

# Internal : Restrict external access to network
# Attachable : Enable container manually attach (swarm)
BODY="
{
  \"Name\": \"${NET_NAME}\",
  \"CheckDuplicate\": false,
  \"Driver\": \"bridge\",
  \"Internal\": ${INTERNAL},
  \"Attachable\": false,
  \"Ingress\": false,
  \"Options\": {
    \"com.docker.network.bridge.enable_icc\": \"true\",
    \"com.docker.network.bridge.enable_ip_masquerade\": \"true\",
    \"com.docker.network.bridge.host_binding_ipv4\": \"0.0.0.0\",
    \"com.docker.network.bridge.name\": \"${NET_NAME}\",
    \"com.docker.network.driver.mtu\": \"1500\"
  }
}"

# RUN command
curl -s -w "%{size_download}\n%{http_code}" -X POST "http://${ADDR}/${API_VERSION}/networks/create" -H "accept: application/json" -H "Content-Type: application/json" -d "${BODY}" | {
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