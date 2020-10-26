#!/bin/bash

source ./common.sh

function install_go_self()
{
    go_version=1.15.3
    download_url=https://golang.org/dl/go${go_version}.linux-amd64.tar.gz

    work_path="/usr/local"
    running_path=${pwd}
    prepare_path ${work_path}

    wget ${download_url} -P ${work_path}
    cd ${work_path}
    tar -xf ${download_url##*/}
    rm -f ${download_url##*/}

    ln -s ${work_path}"/go/bin/go" ${work_path}"/../bin/go"
}

function install_go()
{
    installed=false
    while :
    do
        verify "go" "go version >/dev/null 2>&1"
        if [ ${?} -ne 0 ];
        then
            if [ ${installed} == false ];
            then
                install_go_self
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
#install_go
#exit 0
