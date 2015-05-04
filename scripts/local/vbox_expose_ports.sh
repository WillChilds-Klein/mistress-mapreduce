#!/usr/bin/env bash

usage="usage: $0 --machines | machine_name [-x] [port1 port2 ...] | [-r port_min port_max]"

report_error () {
    echo $usage
    exit 1
}

cmd="expose"
machine=$1

if [[ $# -lt 1 ]]; then
    report_error
elif [[ $1 = "--machines" ]]; then
    echo "RUNNING VBOX MACHINES: $(VBoxManage list runningvms | awk '{print $1}' | xargs)"
    exit $?
elif [[ $2 = "-r" && $# -eq 4 ]]; then
    ports=$(seq $2 $3)
    shift 2
elif [[ $2 = "-r" ]]; then
    report_error
elif [[ $2 = "-x" ]]; then
    cmd="delete"
    shift 2
else
    shift 1
fi

ports="$@"

for port in ${ports}; do
    if [[ ${cmd} = "delete" ]]; then
        echo "HIDING PORT ${port} ON ${machine}"
        VBoxManage controlvm ${machine} natpf1 delete "tcp-port$port"
        VBoxManage controlvm ${machine} natpf1 delete "udp-port$port"
    else
        echo "FORWARDING PORT ${port} ON ${machine}"
        VBoxManage controlvm ${machine} natpf1 "tcp-port$port,tcp,,$port,,$port"
        VBoxManage controlvm ${machine} natpf1 "udp-port$port,udp,,$port,,$port"
    fi
done
