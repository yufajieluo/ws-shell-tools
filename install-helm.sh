#!/bin/bash

source ./common.sh

function install_self()
{
    version=v3.7.0
    download_url=https://get.helm.sh/helm-${version}-linux-amd64.tar.gz

    work_path="/usr/local/bin"
    prepare_path ${work_path}

    wget ${download_url} -P .
    tar -xf ${download_url##*/}
    rm -f ${download_url##*/}

    cp -f linux-amd64/helm ${work_path}
    if [ -d linux-amd64 ];
    then   
        rm -rf linux-amd64
    fi
}

function install()
{
    installed=false
    while :
    do
        verify "helm" "helm version >/dev/null 2>&1"
        if [ ${?} -ne 0 ];
        then
            if [ ${installed} == false ];
            then
                install_self
                installed=true
                continue
            else
                break
            fi
        else
            break
        fi
    done
}

############
# for test #
############
install
exit 0
