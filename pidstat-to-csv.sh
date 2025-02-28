#! /usr/bin/bash

# This script reads a pidstat file and outputs a CSV file
$file=$1

echo "timestamp,wait,used,core,command"

function read_pidstat_file() {
    file=$1
    cat $file | grep -vE "^$|\%usr|grid5000|Average"
}

read_pidstat_file $file \
    | awk -v cpu=$ncpu -v flow=$nflow -v run=$nrun '{ print cpu,flow,run,$1,$8,$9,$10,$11 }' \
    | tr ' ' ','