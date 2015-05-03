#!/usr/bin/env bash

[ -e input_paths.txt ] && rm -f input_paths.txt

for file in input/*.txt; do
    echo "$file" >> input_paths.txt
done
