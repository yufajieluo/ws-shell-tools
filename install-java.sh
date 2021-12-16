#!/bin/bash

source ./common.sh

function install_java_self()
{
    download_url=http://45.76.247.122:9000/public/jdk-8u231-linux-x64.tar.gz

    work_path="/usr/local/java"
    running_path=${pwd}
    prepare_path ${work_path}

    wget ${download_url} -P ${work_path}
    cd ${work_path}
    tar -zxf ${download_url##*/}
    rm -f ${download_url##*/}

    paths=($(ls ${work_path}))
    chown root:root -R ${paths[0]}
    ln -s ${work_path}"/"${paths[0]}"/bin/java" ${work_path}"/../bin/java"
    ln -s ${work_path}"/"${paths[0]}"/bin/java" "/usr/bin/java"

    sed -i "/JAVA_HOME/d" /etc/profile
    echo "" >> /etc/profile
    echo "export JAVA_HOME=${work_path}/${paths[0]}" >> /etc/profile
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
    echo "export CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib" >> /etc/profile
    source /etc/profile
    cd ${running_path}
}

function install_java()
{
    installed=false
    while :
    do
        verify "java" "java -version >/dev/null 2>&1"
        if [ ${?} -ne 0 ];
        then
            if [ ${installed} == false ];
            then
                install_java_self
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
#install_java
#exit 0
