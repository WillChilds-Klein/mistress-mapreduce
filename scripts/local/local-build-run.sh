#!/usr/bin/env bash

usage="usage: $0 [local_master=local1]"
if [[ $# -gt 2 ]]; then
    echo $usage
    exit 1
fi

esc=$(printf '\033');
red="${esc}[31m";
green="${esc}[32m";
blue="${esc}[34m";
none="${esc}[0m";

docker_host=${1-"local1"}
img_repo="willck/mistress-mapreduce"
img_tag=":local"

master=${MISTRESS_MASTER:-"master"}
master_host=${1:-"$(docker-machine ip $docker_host)"}
master_port=${MISTRESS_MASTER_PORT:-"8080"}

# switch to scripts folder to avoid sending huge build 
# context to docker daemon
init_dir=$(pwd)
mistress_dir="/Users/will/work/classes/cpsc490/code/mistress-mapreduce"
cd ${mistress_dir}


# swich to local docker host
docker-machine active $docker_host && \
  eval $(docker-machine env ${docker_host})
echo "${blue}HOST MACHINE${none}: $(docker-machine active)"
printf "${green}DOCKER ENV${none}:\n $(docker-machine env)\n\n"

# build image
echo "BUILDING DOCKER IMAGE"
docker build -f "${mistress_dir}/scripts/local/Dockerfile.local" \
             -t ${img_repo}${img_tag} \
         ${mistress_dir} \
           && printf "\n\nBUILD ${green}SUCCESS${none}\n\n" \
           || printf "\n\nBUILD ${red}FAILURE${none}\n\n"

# remove all existing containers
containers=$(docker ps -aq | xargs)
for container in ${containers}; do
    echo "${red}KILLING CONTAINER${none} ${container}"
    docker kill ${container}
    docker rm --force ${container}
done

printf "\n\n"

# cd to mistress-mapreduce root dir to grab input files at runtime
cd ${mistress_dir}

# run master
echo "${blue}RUNNING${none} MASTER"
docker run -d --name master --net host \
             -v "${mistress_dir}/:/mistress-mapreduce/" \
             -w /mistress-mapreduce \
         ${img_repo}${img_tag} scripts/local/local-run.sh \
              -i input_paths.txt -o output -t wordcount2-master.txt \
            wordcount2.py $master_port

printf "\n\n"
sleep 3

# run slave
echo "${blue}RUNNING${none} SLAVE"
docker run -d --name slave --net host \
             -v "${mistress_dir}/:/mistress-mapreduce/" \
             -w /mistress-mapreduce \
         ${img_repo}${img_tag} scripts/local/local-run.sh \
             -s ${master_host} -t wordcount2-slave.txt \
           wordcount2.py $master_port

printf "\n\n${blue}DONE${none}!\n\n"

# show master logs
echo "${green}MASTER LOGS${none}:"
docker logs master | tail -n 10
