#!/usr/bin/env bash
## pull-all.sh

machines=$(docker-machine ls -q | xargs)
echo "machines: $machines"

esc=$(printf '\033');
red="${esc}[31m";
green="${esc}[32m";
blue="${esc}[34m";
none="${esc}[0m";

for machine in $machines; do
    # set env for curr machine
    docker-machine active $machine
    eval $(docker-machine env $machine)

    # pull latest clean image
    docker pull willck/mistress:latest & #| \
      #grep -i download | \
      #echo "${green}$machine:${none} $(cat -)" &
done

# wait for all images to be pulled before exiting
wait
