#!/usr/bin/env bash
## local-run.sh

mistress_dir="/Users/will/work/classes/cpsc490/code/mistress-mapreduce"
init_dir=$(pwd)


cd mistress_dir && \
scripts/install-mistress.sh && \
    scripts/run-job.sh $@

cd init_dir
