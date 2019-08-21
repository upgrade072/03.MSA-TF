#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

# USAGE
if [ "$#" -ne 3 ]; then
  echo "# create volume container [addr repo:tag node_name]"
  echo "$0 192.168.70.27:2736 volume:1.0 LB01"
  exit -1
fi

API_VERSION=v1.39
ADDR=$1
REPO_TAG=$2
NODE_NAME=$3
ARG_CONTAINER_ENV=$(cat ./${NODE_NAME}.env)

CONTAINER_NAME="VOLUME_CONTAINER_${NODE_NAME}"

BODY="
{
  \"Env\": [
	${ARG_CONTAINER_ENV}
  ],
  \"Image\": \"${REPO_TAG}\",
  \"HostConfig\": {
    \"Binds\": [ \"/node_data/${NODE_NAME}/data:/data\", \"/node_data/${NODE_NAME}/log:/log\", \"/node_data/${NODE_NAME}/tmp:/tmp\" ],
    \"IpcMode\" : \"shareable\"
  }
}"

# RUN command
curl -s -w "%{size_download}\n%{http_code}" -X POST "http://${ADDR}/${API_VERSION}/containers/create?name=${CONTAINER_NAME}" -H "accept: application/json" -H "Content-Type: application/json" -d "${BODY}" | {
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
