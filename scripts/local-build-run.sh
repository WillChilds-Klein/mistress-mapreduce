#!/usr/bin/env bash

usage="usage: $0 [local_master=local]"
if [[ $# -gt 2 ]]; then
    echo $usage
    exit 1
fi

esc=$(printf '\033');
red="${esc}[31m";
green="${esc}[32m";
blue="${esc}[34m";
none="${esc}[0m";

docker_host=${1-"local"}
img_repo="willck/mistress-mapreduce"
img_tag="local"

master=${MISTRESS_MASTER:-"master"}
master_host=${1:-"$(docker-machine ip $docker_host)"}
master_port=${MISTRESS_MASTER_PORT:-"8080"}

# switch to mistress-mapreduce dir
init_dir=$(pwd)
mistress_dir="/Users/will/work/classes/cpsc490/code/mistress-mapreduce"


# swich to local docker host
docker-machine active $docker_host && \
  eval $(docker-machine env ${docker_host})
echo "${blue}HOST MACHINE${none}: $(docker-machine active)"
printf "${green}DOCKER ENV${none}:\n $(docker-machine env)\n\n"

# remove all existing containers
containers=$(docker ps -aq | xargs)
for container in ${containers}; do
    echo "${red}KILLING CONTAINER${none} ${container}"
    docker kill ${container}
    docker rm --force ${container}
done

printf "\n\n"

# build image
echo "BUILDING DOCKER IMAGE"
docker build -t ${img_repo}:${img_tag}  \
         ${mistress_dir} \
           && printf "\n\nBUILD ${green}SUCCESS${none}\n\n" \
           || printf "\n\nBUILD ${red}FAILURE${none}\n\n"

printf "\n\n"

# run master
echo "${blue}RUNNING${none} MASTER"
docker run -d --name master --net host \
           -v ${mistress_dir}:/mistress-mapreduce \
         ${img_repo}:${img_tag} scripts/run-job.sh \
              -i input_paths.txt -o output -t wordcount2-master.txt \
            wordcount2.py $master_port

printf "\n\n"
sleep 10

# run slave
echo "${blue}RUNNING${none} SLAVE"
docker run -d --name slave --net host \
           -v ${mistress_dir}:/mistress-mapreduce \
         ${img_repo}:${img_tag} scripts/run-job.sh \
             -s ${master_host} -t wordcount2-slave.txt \
           wordcount2.py $master_port

printf "\n\n${blue}DONE${none}!\n\n"

# show master logs
echo "${green}MASTER LOGS${none}:"
docker logs master | tail -n 10
