#!/bin/bash

HARBOR_ADDR=10.100.101.199
HARBOR_PATH_CRT=/tmp/test.crt
HARBOR_PATH_KEY=/tmp/test.key
HARBOR_VOLUME=/data-harbor
WORK_PATH=/root/harbor-test
HARBOR_VERSION=v2.3.0
DOWNLOAD_URL=https://github.com/goharbor/harbor/releases/download/${HARBOR_VERSION}/harbor-offline-installer-${HARBOR_VERSION}.tgz

wget ${DOWNLOAD_URL} -O ${WORK_PATH}"/"${DOWNLOAD_URL##*/}

cd ${WORK_PATH}

tar -zxvf ${DOWNLOAD_URL##*/}

cp harbor/harbor.yml.tmpl harbor/harbor.yml

sed -i "s/hostname: reg.mydomain.com/hostname: ${HARBOR_ADDR}/g" harbor/harbor.yml

replace_str=`echo ${HARBOR_PATH_CRT} | sed 's#\/#\\\/#g'`
sed -i "s/\/your\/certificate\/path/${replace_str}/g" harbor/harbor.yml

replace_str=`echo ${HARBOR_PATH_KEY} | sed 's#\/#\\\/#g'`
sed -i "s/\/your\/private\/key\/path/${replace_str}/g" harbor/harbor.yml

replace_str=`echo ${HARBOR_VOLUME} | sed 's#\/#\\\/#g'`
sed -i "s/data_volume: \/data/data_volume: ${replace_str}/g" harbor/harbor.yml

./prepare

./install.sh

docker-compose ps
