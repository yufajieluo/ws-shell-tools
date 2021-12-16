#!/bin/bash

source ./common.sh

function install_node_self()
{
    node_version=v12.16.3
    download_url=https://nodejs.org/dist/${node_version}/node-${node_version}-linux-x64.tar.xz

    work_path="/usr/local/node"
    running_path=${pwd}
    prepare_path ${work_path}

    wget ${download_url} -P ${work_path}
    cd ${work_path}
    tar -xf ${download_url##*/}
    rm -f ${download_url##*/}

    paths=($(ls ${work_path}))
    chown root:root -R ${paths[0]}
    ln -s ${work_path}"/"${paths[0]}"/bin/node" ${work_path}"/../bin/node"
    ln -s ${work_path}"/"${paths[0]}"/bin/npm" ${work_path}"/../bin/npm"
    ln -s ${work_path}"/"${paths[0]}"/bin/node" "/usr/bin/node"
    ln -s ${work_path}"/"${paths[0]}"/bin/npm" "/usr/bin/npm"
    cd ${running_path}
}

function install_node()
{
    installed=false
    while :
    do
        verify "node" "node -v >/dev/null 2>&1"
        if [ ${?} -ne 0 ];
        then
            if [ ${installed} == false ];
            then
                install_node_self
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
#install_node
#exit 0
