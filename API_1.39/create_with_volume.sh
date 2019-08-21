#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

# USAGE
if [ "$#" -lt 4 ]; then
  echo "# create container connected with volume [addr node_name repo:tag name [<conainer_expose:host_bind>]]"
  echo "$0 192.168.70.27:2736 LB01 ixpc:0.1 LB01_IXPC_0.1 5000:7001,5001:7002,5002:7003"
  exit -1
fi

FUNC_CHECK_RES() {
    if [ $RES -ge 200 ] && [ $RES -lt 300 ]; then
	:
    else
        echo ${BODY} | jq .
        exit $RES
    fi;
}

API_VERSION=v1.39
ADDR=$1
NODE_NAME=$2
REPO_TAG=$3
NAME=$4
EXPOSE_ARRAY=$5

BODY=$(./base_inspect.sh ${ADDR} VOLUME_CONTAINER_${NODE_NAME})
RES=$?
FUNC_CHECK_RES

ARG_CONTAINER_ENV=$(echo ${BODY} | jq .Config.Env)

if [ -z $EXPOSE_ARRAY ]
then
	PORT_BINDING_STR=""
else
	PORT_BINDING_STR=
	IFS=',' read -ra PORT_BIND <<< "$EXPOSE_ARRAY"
	POS=$((${#PORT_BIND[*]} - 1))
	LAST=${PORT_BIND[${POS}]}
	for i in "${PORT_BIND[@]}"; do
	    read EXPOSE_PORT BIND_PORT <<< $(echo ${i} | awk -F ":"  '{print $1 " " $2}')
	    if [[ ${i} == $LAST ]]
	    then
		COMMA=""
	    else
		COMMA=","
	    fi
	    PORT_BINDING_STR+="\"${EXPOSE_PORT}/tcp\":[ { \"HostIp\":\"\",\"HostPort\":\"${BIND_PORT}\"} ]${COMMA}"
	    ADDITIONAL_ENV="\"EXPOSE_${EXPOSE_PORT}=${BIND_PORT}\""
	    ARG_CONTAINER_ENV=$(echo ${ARG_CONTAINER_ENV} | jq '.[length] |= . + '${ADDITIONAL_ENV}'')
	done
fi

BODY="
{
  \"Image\": \"${REPO_TAG}\",
  \"Env\": ${ARG_CONTAINER_ENV},
  \"HostConfig\": {
    \"IpcMode\" : \"container:VOLUME_CONTAINER_${NODE_NAME}\",
    \"VolumesFrom\": [
      \"VOLUME_CONTAINER_${NODE_NAME}\"
      ],
      \"PortBindings\": {
        ${PORT_BINDING_STR}
      }
    }
}"

# RUN command
curl -s -w "%{size_download}\n%{http_code}" -X POST "http://${ADDR}/${API_VERSION}/containers/create?name=${NAME}" -H "accept: application/json" -H "Content-Type: application/json" -d "${BODY}" | {
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
