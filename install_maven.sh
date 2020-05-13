#!/bin/bash

source ./common.sh

function install_maven_self()
{
    maven_version=3.6.3
    download_url=https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz

    work_path="/usr/local/maven"
    running_path=${pwd}
    prepare_path ${work_path}

    wget ${download_url} -P ${work_path}
    cd ${work_path}
    tar -zxf ${download_url##*/}
    rm -f ${download_url##*/}

    paths=($(ls ${work_path}))
    chown root:root -R ${paths[0]}
    ln -s ${work_path}"/"${paths[0]}"/bin/mvn" ${work_path}"/../bin/mvn"
    ln -s ${work_path}"/"${paths[0]}"/bin/mvn" "/usr/bin/mvn"
    cd ${running_path}
}

function install_maven()
{
    installed=false
    while :
    do
        verify "maven" "mvn -h >/dev/null 2>&1"
        if [ ${?} -ne 0 ];
        then
            if [ ${installed} == false ];
            then
                install_maven_self
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
#install_maven
#exit 0
