#!/bin/bash

source ./common.sh

function install_scala_self()
{
    scala_version=2.11.12
    download_url=https://downloads.lightbend.com/scala/${scala_version}/scala-${scala_version}.tgz

    work_path="/usr/local/scala"
    running_path=${pwd}
    prepare_path ${work_path}

    wget ${download_url} -P ${work_path}
    cd ${work_path}
    tar -zxf ${download_url##*/}
    rm -f ${download_url##*/}

    paths=($(ls ${work_path}))
    chown root:root -R ${paths[0]}
    ln -s ${work_path}"/"${paths[0]}"/bin/scala" ${work_path}"/../bin/scala"
    ln -s ${work_path}"/"${paths[0]}"/bin/scala" "/usr/bin/scala"
    cd ${running_path}
}

function install_scala()
{
    installed=false
    while :
    do
        verify "scala" "scala -help >/dev/null 2>&1"
        if [ ${?} -ne 0 ];
        then
            if [ ${installed} == false ];
            then
                install_scala_self
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
#install_scala
#exit 0
