#!/bin/bash

# USAGE
if [ "$#" -ne 1 ]; then
  echo "# list all of images [remote_addr]"
  echo "$0 192.168.70.27:2736"
  exit -1
fi

BODY=$(./base_images.sh $@)
RES=$?

echo $BODY | jq '.[] | { "Id": .Id, "RepoTags": .RepoTags[0], "Labels": .Labels}'
exit $RES
