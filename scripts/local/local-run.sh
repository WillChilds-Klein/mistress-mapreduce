#!/usr/bin/env bash
## local-run.sh

mistress_dir="/mistress-mapreduce"

cd ${mistress_dir} && \
scripts/install-mistress.sh && \
    scripts/run-job.sh $@
