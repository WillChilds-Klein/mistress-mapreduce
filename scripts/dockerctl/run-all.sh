#!/usr/bin/env bash

usage="usage: $0 [master_host]"
if [[ $# -gt 1 ]]; then
    echo $usage
    exit 1
fi

esc=$(printf '\033');
red="${esc}[31m";
green="${esc}[32m";
yellow="${esc}[33m";
blue="${esc}[34m";
none="${esc}[0m";

datetime=$(date +%Y-%m-%d.%H:%M:%S)

img_repo="willck/mistress-mapreduce"
img_tag="latest"

master=${MISTRESS_MASTER:-"master"}
master_host=${1:-"$(docker-machine ip $master)"}
master_port=${MISTRESS_MASTER_PORT:-"8080"}
echo "master: ${master}@${master_host}:${master_port}"

# switch docker cli control to master node
docker-machine active $master && \
  eval $(docker-machine env $master)

docker run -d --name master --net host \
        ${img_repo}:${img_tag} scripts/run-job.sh \
            -i input_paths.txt -o output -t master-wordcount2-${datetime}.txt \
           wordcount2.py $master_port


slaves=$(docker-machine ls -q | grep -e '^remote' | xargs)
echo "slaves: $slaves"

((i = 1))
for slave in $slaves; do
    # set env for curr machine
    docker-machine active $slave
    eval $(docker-machine env $slave)

    # execute enslavement
    docker run -d --name "slave${i}" --net host \
            ${img_repo}:${img_tag} scripts/run-job.sh \
            -s ${master_host} -t "slave${i}-wordcount2-${datetime}.txt" \
               wordcount2.py $master_port

    ((i++))
done

# switch docker cli back to master for log checking
docker-machine active $master && \
  eval $(docker-machine env $master)


# open up a bash shell in master
#docker exec -it master /bin/bash

# wait for job to (hopefully) finish
sleep 15

#alias green-grep="GREP_COLOR='1;32' grep --color=always"
#alias yellow-grep="GREP_COLOR='1;33' grep --color=always"
docker logs master #| green-grep -E '^|Reduce: 100' \
                   #| yellow-grep -E '^|Map: 100'
