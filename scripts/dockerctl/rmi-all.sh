#!/usr/bin/env bash

help="USAGE: $0 [-a]"
if [[ $# -gt 1 ]]; then
    echo $help
    exit 1
fi

# COLOR ESC NUMS
#30	Black
#31	Red
#32	Green
#33	Yellow
#34	Blue
#35	Magenta
#36	Cyan

esc=$(printf '\033');
red="${esc}[31m";
green="${esc}[32m";
yellow="${esc}[33m";
blue="${esc}[34m";
none="${esc}[0m";


OPTIND=1
rm_all=0

while getopts "h?:a" opt; do
    case "$opt" in
    h|\?)
        echo $help
        exit 0
        ;;
    a)  rm_all=1
        echo "${blue}DELETING ${red}ALL${blue} IMAGES ON ${red}ALL${blue} MACHINES${none} (docker rmi -a)"
        ;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift

machines=$(docker-machine ls -q)

for machine in $machines; do
    echo "${blue}DELETING $([ $rm_all -eq 1 ] && printf "${red}ALL" || printf "${green}RECENT")${blue} IMAGES ON MACHINE: ${yellow}$machine${none}"

    docker-machine active $machine
    eval $(docker-machine env $machine)

    [ $rm_all ] && opts="-aq" || opts="-q"

    #images=$(docker images $opts | xargs)
    #for image in $images; do
        #docker rmi --force $image
    #done

    docker images $opts | xargs docker rmi --force
done
