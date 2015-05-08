#!/usr/bin/env bash
## run-job.sh
# TODO: -s and {-o,-i} should never be specified together

help="USAGE: $0 [-s master_host XOR -i input_file -o output_dir] [-t timing_file] job_file master_port"

timing_file=""
role="Master"
input_file="input_paths.txt"
output_dir="output"
master_host=""

OPTIND=1
while getopts "h?s:i:o:t:" opt; do
    case "$opt" in
    h|\?)
        echo $help
        exit 0
        ;;
    t)  timing_file=$OPTARG
        ;;
    s)  master_host=$OPTARG
        role="Slave"
        ;;
    o)  output_dir=$OPTARG
        ;;
    i)  input_file=$OPTARG
        ;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift


if [[ $# -ne 2 ]]; then
    echo $help
    exit 1
fi


job="jobs/${1}"
port="${2}"
timing_file="timer/$([ -z $timing_file ] \
                        && echo ${role}.txt \
                        || echo $timing_file)"


python $job -I $role $([ $role = Master ] \
                        && echo -n "-P ${port} ${input_file} ${output_dir}" \
                        || echo -n "-M ${master_host}:${port}") \
        --mrs-timing-file ${timing_file} --mrs-profile --mrs-verbose

echo "${green}OUTPUT${none}:"
for out in ${output_dir}/* ; do 
    echo "file $out:"
    cat $out
done
echo

echo "${yellow}TIME${none}:"
echo "file $timing_file:"
cat $timing_file
echo

#echo "${blue}PROFILE${none}:"
#for prof in mrsprof/* ; do 
    #echo "file $prof:"
    #cat $prof
#done
#echo

# keep container running for 5 minutes
sleep 300
