#!/bin/bash

SERVER_NAME="set-hostname"
SERVER_VERSION="v1.0.0"
COLOR_ERROR="31m"
COLOR_SUCCESS="32m"

function help()
{
    echo "Usage:"
    echo "  ${SERVER_NAME} [OPTION]"
    echo ""
    echo "Available OPTION"
    echo "  --name     必填"
    echo ""
    echo "  --help     display this help and exit"
    echo "  --version  output version information and exit"
}

function version()
{
    echo "${SERVER_NAME} ${SERVER_VERSION}"
}

function print_color()
{
    echo -e "\033[${1}${2}\033[0m"
}

function set_hostname()
{
    if [ -z ${hostname} ];
    then
        print_color ${COLOR_ERROR} "hostname must not empty."
    else
        hostnamectl set-hostname ${hostname}
        print_color ${COLOR_SUCCESS} "set hostname ${hostname} success."
    fi
}

########## main ##########

ARGS=`getopt -o t:,b: --long help,version,name: -- "$@"`
if [ $# == 0 ];
then
    help
    echo ""
    echo "Terminating..." >&2
    exit 1
fi

if [ $? != 0 ];
then
    echo "Terminating..." >&2
    exit 1
fi

eval set -- "$ARGS"

hostname=

while true
do
    case "$1" in
        --help)
            help
            break
            ;;
        --version)
            version
            break
            ;;
        --name)
            hostname=$2
            set_hostname
            shift 2
            ;;
        --)
            shift
            break
            ;;
    esac
done
