#!/usr/bin/env bash

usage="usage: $0 [master_host]"
if [[ $# -gt 1 ]]; then
    echo $usage
    exit 1
fi


master=${MISTRESS_MASTER:-"master"}
master_host=${1:-"$(docker-machine ip $master)"}
master_port=${MISTRESS_MASTER_PORT:-"8080"}
echo "master: ${master}@${master_host}:${master_port}"

docker-machine active $master && \
  eval $(docker-machine env $master)

docker run -d --name master --net host willck/mistress-mapreduce:latest \
        ${img_repo}${img_tag} scripts/run-job.sh \
              -i input_paths.txt -o output -t wordcount2-master.txt \
            wordcount2.py $master_port


slaves=$(docker-machine ls -q | grep remote | xargs)
echo "slaves: $slaves"

((i = 1))
for slave in $slaves; do
    # set env for curr machine
    docker-machine active $slave
    eval $(docker-machine env $slave)

    # execute enslavement
    docker run -d --name "slave${i}" --net host willck/mistress-mapreduce:latest \
            ${img_repo}${img_tag} scripts/run-job.sh \
              -s ${master_host} -t "wordcount2-slave${i}.txt" \
           wordcount2.py $master_port

    ((i++))
done
