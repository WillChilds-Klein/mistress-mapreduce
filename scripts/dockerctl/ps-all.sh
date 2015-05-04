#!/usr/bin/env bash
## ps-all.sh

help="USAGE: $0 [-a]"

esc=$(printf '\033');
red="${esc}[31m";
green="${esc}[32m";
blue="${esc}[34m";
none="${esc}[0m";

OPTIND=1
list_all=0

while getopts "h?:a" opt; do
    case "$opt" in
    h|\?)
        echo $help
        exit 0
        ;;
    a)  list_all=1
        ;;
    esac
done
shift $((OPTIND-1))


machines=$(docker-machine ls -q)

for machine in $machines; do
    docker-machine active $machine
    eval $(docker-machine env $machine)

    echo "CONTAINERS ON ${blue}$machine${none}"
    [ $list_all ] && docker ps -a || docker ps
    printf "\n"
done
