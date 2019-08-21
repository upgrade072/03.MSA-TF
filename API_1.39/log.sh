#!/usr/bin/bash

# API version: 1.39
# https://docs.docker.com/engine/api/v1.39/#

API_VERSION=v1.39
ADDR=$1
ID=$2
CNT=$3

# USAGE
if [ "$#" -ne 3 ]; then
  echo "# logs from container [remote_addr container_id tail_num]"
  echo "$0 192.168.70.27:2736 VOLUME_CONTAINER_LB1 1000"
  exit -1
fi

# RUN command
curl -s -X GET "http://${ADDR}/${API_VERSION}/containers/${ID}/logs?follow=false&stdout=true&stderr=true&since=0&timestamps=true&tail=${CNT}" -H "accept: application/json" 
[schlee@localhost API_V1.26]$ !!
cat ./logs.sh 
#!/usr/bin/bash

# API version: 1.26 (minimum version 1.12)
# https://docs.docker.com/engine/api/v1.26/#

API_VERSION=v1.26
ADDR=$1
ID=$2
CNT=$3

# USAGE
if [ "$#" -ne 3 ]; then
  echo "# logs from container [remote_addr container_id tail_num]"
  echo "./logs.sh 192.168.159.152:2736 e19c5f00830f435bb765458d2400ca13ebd5e94221118468bb62ca89e1e1b25a 1000"
  exit -1
fi

# RUN command
curl -s -X GET "http://${ADDR}/${API_VERSION}/containers/${ID}/logs?follow=false&stdout=true&stderr=true&since=0&timestamps=true&tail=${CNT}" -H "accept: application/json" 
