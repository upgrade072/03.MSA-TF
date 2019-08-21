#!/bin/bash

# USAGE
if [ "$#" -ne 4 ]; then
  echo "# test script [addr] [node_name] [expose ixpc] [expose https]"
  echo "$0 192.168.70.27:2736 LB01 29697:29697 6000:16000,6001:16001,6002:16002,9000:9000,9001:9001,9002:9002,9003:9003"
  exit -1
fi

ADDR=$1
NODE=$2
IXPC_EXPOSE=$3
HTTPS_EXPOSE=$4

FUNC_CHECK_RES() {
    if [ $RES -ge 200 ] && [ $RES -lt 300 ]; then
	echo ${BODY} | jq .
        echo "===>>> success with $RES"
    else
        echo ${BODY}
        exit "===>>> failed with $RES"
    fi;
}

FUNC_PRINT_RES() {
    echo ${BODY} | jq .
    echo "===>>> response with $RES"
}

# check containers exist
echo ""
echo "[check volumes:1.0 exist in ${ADDR}]"
BODY=$(./check_image.sh ${ADDR} volume:1.0)
RES=$?
FUNC_CHECK_RES
echo ""
echo "[check ixpc:0.1 exist in ${ADDR}]"
BODY=$(./check_image.sh ${ADDR} ixpc:0.1)
RES=$?
FUNC_CHECK_RES
echo ""
echo "[check httpc:0.1 exist in ${ADDR}]"
BODY=$(./check_image.sh ${ADDR} httpc:0.1)
RES=$?
FUNC_CHECK_RES
echo ""
echo "[check https:0.1 exist in ${ADDR}]"
BODY=$(./check_image.sh ${ADDR} https:0.1)
RES=$?
FUNC_CHECK_RES
echo ""
echo "<<< all containers exist >>>"
echo "<<< wait for sec before network created >>>"
sleep 1

NET_NAME_INNER="LB_HTTP_INNER"
NET_NAME_OUTER="LB_HTTP_OUTER"

# create network
echo ""
echo "[create network ${NET_NAME_INNER} in ${ADDR}]"
BODY=$(./crt_network.sh ${ADDR} ${NET_NAME_INNER} true)
RES=$?
FUNC_PRINT_RES
echo ""
echo "[create network ${NET_NAME_OUTER} in ${ADDR}] <<< predefined val [2001:db8:2::1 2001:db8:2::/64] >>>"
BODY=$(./crt_network_ipv6.sh ${ADDR} ${NET_NAME_OUTER} 2001:db8:2::1 2001:db8:2::/64)
RES=$?
FUNC_PRINT_RES
echo ""
echo "<<< all network created >>>"
echo "<<< wait for sec before network exist check >>>"
sleep 1

# check network exist 
echo ""
echo "[check network ${NET_NAME_INNER} exist in ${ADDR}]"
BODY=$(./check_network.sh ${ADDR} ${NET_NAME_INNER})
RES=$?
FUNC_PRINT_RES
echo ""
echo "[check network ${NET_NAME_OUTER} exist in ${ADDR}]"
BODY=$(./check_network.sh ${ADDR} ${NET_NAME_OUTER})
RES=$?
FUNC_PRINT_RES
echo ""
echo "<<< all network exist >>>"

# create volume container
echo ""
echo "[create volume container for ${NODE} with env file ${NODE}.env]"
BODY=$(./crt_volume.sh ${ADDR} volume:1.0 ${NODE})
RES=$?
FUNC_CHECK_RES
echo ""
echo "<<< volume container created >>>"
echo "<<< wait for sec before container created >>>"
sleep 1

# create containers
echo ""
echo "[create ixpc container expose(${IXPC_EXPOSE})"
BODY=$(./create_with_volume.sh ${ADDR} ${NODE} ixpc:0.1 ${NODE}_IXPC_0.1 ${IXPC_EXPOSE})
RES=$?
FUNC_CHECK_RES
echo ""
echo "[create httpc container expose(none)]"
BODY=$(./create_with_volume.sh ${ADDR} ${NODE} httpc:0.1 ${NODE}_HTTPC_0.1)
RES=$?
FUNC_CHECK_RES
echo ""
echo "[create https container expose(${HTTPS_EXPOSE})"
BODY=$(./create_with_volume.sh ${ADDR} ${NODE} https:0.1 ${NODE}_HTTPS_0.1 ${HTTPS_EXPOSE})
RES=$?
FUNC_CHECK_RES
echo ""
echo "<<< ixpc httpc https container created >>>"
echo "<<< wait for sec before network arranged >>>"
sleep 1

# network arrange
echo ""
echo "[disconnect bridge from httpc]"
BODY=$(./disconnect_network.sh ${ADDR} bridge ${NODE}_HTTPC_0.1)
RES=$?
FUNC_PRINT_RES
echo ""
echo "[disconnect bridge from https]"
BODY=$(./disconnect_network.sh ${ADDR} bridge ${NODE}_HTTPS_0.1)
RES=$?
FUNC_PRINT_RES
echo ""
echo "[connect ${NET_NAME_INNER} to httpc]"
BODY=$(./connect_network.sh ${ADDR} ${NET_NAME_INNER} ${NODE}_HTTPC_0.1)
RES=$?
FUNC_PRINT_RES
echo ""
echo "[connect ${NET_NAME_OUTER} to httpc]"
BODY=$(./connect_network.sh ${ADDR} ${NET_NAME_OUTER} ${NODE}_HTTPC_0.1)
RES=$?
FUNC_PRINT_RES
echo ""
echo "[connect ${NET_NAME_INNER} to https]"
BODY=$(./connect_network.sh ${ADDR} ${NET_NAME_INNER} ${NODE}_HTTPS_0.1)
RES=$?
FUNC_PRINT_RES
echo ""
echo "[connect ${NET_NAME_OUTER} to https]"
BODY=$(./connect_network.sh ${ADDR} ${NET_NAME_OUTER} ${NODE}_HTTPS_0.1)
RES=$?
FUNC_PRINT_RES
echo ""
echo "<<< all network arranged >>>"
echo "<<< wait for sec before container started>>>"
sleep 1

# start container
echo ""
echo "[volume container start]"
BODY=$(./start.sh ${ADDR} VOLUME_CONTAINER_${NODE})
RES=$?
FUNC_PRINT_RES
sleep 1
echo ""
echo "[ixpc container start]"
BODY=$(./start.sh ${ADDR} ${NODE}_IXPC_0.1)
RES=$?
FUNC_PRINT_RES
sleep 1
echo ""
echo "[httpc container start]"
BODY=$(./start.sh ${ADDR} ${NODE}_HTTPC_0.1)
RES=$?
FUNC_PRINT_RES
sleep 1
echo ""
echo "[https container start]"
BODY=$(./start.sh ${ADDR} ${NODE}_HTTPS_0.1)
RES=$?
FUNC_PRINT_RES
sleep 1
