#!/bin/bash

source ./common.sh

download_url_bz2=http://45.76.247.122:9000/public/_bz2.cpython-VERSION-x86_64-linux-gnu.so
download_url_flink=http://45.76.247.122:9000/public/apache-flink-1.10.1.tar.gz
lib_url_csv=https://repo.maven.apache.org/maven2/org/apache/flink/flink-csv/1.10.0/flink-csv-1.10.0.jar
lib_url_csv_sql=https://repo.maven.apache.org/maven2/org/apache/flink/flink-csv/1.10.0/flink-csv-1.10.0-sql-jar.jar
lib_url_json=https://repo.maven.apache.org/maven2/org/apache/flink/flink-json/1.10.0/flink-json-1.10.0.jar
lib_url_json_sql=https://repo.maven.apache.org/maven2/org/apache/flink/flink-json/1.10.0/flink-json-1.10.0-sql-jar.jar
lib_url_jdbc=https://repo.maven.apache.org/maven2/org/apache/flink/flink-jdbc_2.11/1.10.0/flink-jdbc_2.11-1.10.0.jar
lib_url_kfk=https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.10.0/flink-sql-connector-kafka_2.11-1.10.0.jar
lib_url_mysql=https://repo.maven.apache.org/maven2/mysql/mysql-connector-java/8.0.19/mysql-connector-java-8.0.19.jar
lib_path=

function prepare_bz2()
{
    match_str_so=lib-dynload
    match_str_lib=site-packages
    result=`python -c "import sys; print(sys.path)"`
    result=${result//\[/}
    result=${result//\]/}
    result=${result//\'/}
    result=${result//,/}
    list=${result// / }
    for path in ${list[@]}
    do
        if [[ ${path} =~ ${match_str_lib} ]];
        then
            lib_path=${path}
        fi

        if [[ ${path} =~ ${match_str_so} ]];
        then
            version=${path##*python}
            version=${version%%/*}
            if [ ${version} == "3.8" ];
            then
                version=${version//./}
            else
                version=${version//./}"m"
            fi
            download_url_bz2=${download_url_bz2//VERSION/${version}}
            
            if [ -f ${path}"/"${download_url_bz2##*/} ];
            then
                print_color "SYSTEM" "_bz模块已准备好, 文件位置: [${path}"/"${download_url_bz2##*/}]."
            else
                print_color "SYSTEM" "_bz模块未准备好, 开始准备..."
                wget ${download_url_bz2} -O ${path}"/"${download_url_bz2##*/}
                if [ $? -eq 0 ];
                then
                    print_color "SYSTEM" "_bz模块已准备好, 文件位置: [${path}"/"${download_url_bz2##*/}]."
                else
                    print_color "ERROR" "_bz模块准备失败, 退出."
                    exit -1
                fi
            fi
        fi
    done
}

function pip_install_flink()
{
    wget ${download_url_flink}
    if [ $? -eq 0 ];
    then
        pip install wheel
        pip install ${download_url_flink##*/} --timeout=120
        python -c "import pyflink"
        rm -f ${download_url_flink##*/}
        if [ $? -ne 0 ];
        then
            print_color "ERROR" "pyflink安装失败."
            exit -1
        fi
    else
        print_color "ERROR" "flink包下载失败, 退出."
    fi
}

function complement_lib()
{
    wget ${lib_url_csv} -O ${lib_path}"/pyflink/lib/"${lib_url_csv##*/}
    wget ${lib_url_csv_sql} -O ${lib_path}"/pyflink/lib/"${lib_url_csv_sql##*/}
    wget ${lib_url_json} -O ${lib_path}"/pyflink/lib/"${lib_url_json##*/}
    wget ${lib_url_json_sql} -O ${lib_path}"/pyflink/lib/"${lib_url_json_sql##*/}
    wget ${lib_url_jdbc} -O ${lib_path}"/pyflink/lib/"${lib_url_jdbc##*/}
    wget ${lib_url_kfk} -O ${lib_path}"/pyflink/lib/"${lib_url_kfk##*/}
    wget ${lib_url_mysql} -O ${lib_path}"/pyflink/lib/"${lib_url_mysql##*/}
    print_color "SUCCESS" "pyflink安装成功."
}

prepare_bz2
pip_install_flink
complement_lib
exit 0
