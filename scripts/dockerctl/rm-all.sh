#!/usr/bin/env bash
## rm-all.sh

esc=$(printf '\033');
red="${esc}[31m";
green="${esc}[32m";
blue="${esc}[34m";
none="${esc}[0m";

machines=$(docker-machine ls -q | grep -e '^[remote][master]*')

for machine in $machines; do
    docker-machine active $machine
    eval $(docker-machine env $machine)
    containers=$(docker ps -aq | xargs)

    for container in $containers; do
        echo "KILLING CONTAINER ${red}${container}${none} ON MACHINE ${blue}${machine}${none}"
        docker kill $container
        docker rm --force $container
    done
done
