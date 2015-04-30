#!/usr/bin/env bash

usage="usage: $0 [master_host]"
#if [[ $# -gt 1 ]]; then
    #echo $usage
    #exit 1
#fi


master=${MISTRESS_MASTER:-"master"}
master_hostname=${1:-"$(docker-machine ip $master)"}
master_port=${MISTRESS_MASTER_PORT:-"8080"}
echo "master: ${master}@${master_hostname}:${master_port}"

docker-machine active $master
eval $(docker-machine env $master)

docker run -d --name master --net host willck/mistress:latest \
           python jobs/wordcount2.py \
             -I Master -P 8080 --mrs-timing-file master-time.txt --mrs-verbose \
             data/ out_dir


slaves=$(docker-machine ls -q | grep remote | xargs)
echo "remote slaves: $machines"

((i = 1))
for machine in $machines; do
    # set env for curr machine
    docker-machine active $mahcine
    eval $(docker-machine env $machine)

    # execute enslavement
    docker run -d --name slave${i} --net host willck/mistress:latest \
           python jobs/wordcount2.py \
             -I Slave -M "${master_hostname}:${master_port}" --mrs-timing-file slave${i}-time.txt --mrs-verbose

    ((i++))
done
