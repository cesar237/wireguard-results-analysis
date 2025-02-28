#! /usr/bin/bash

function get_safe_params() {
    if ! [[ "$#" == "1" || "$#" == "2" ]]; then
        echo "Usage: $0 <sar_file> [-q]"
        exit 1
    fi
    file=$1

    if [[ "$2" == "-q" ]]; then
        quiet=true
    else
        quiet=false
    fi
    echo $file $quiet
}

function read_pidstat_file() {
    file=$1
    cat $file | grep -vE "^$|\%usr|grid5000|Average"
}

function parse_pidstat() {
    # This script reads a pidstat file and outputs a CSV file
    params=$(get_safe_params $@)
    file=$(echo $params | cut -d ' ' -f 1)
    quiet=$(echo $params | cut -d ' ' -f 2)
    if [[ "$quiet" == "false" ]]; then
        echo "timestamp,wait,used,core,command"
    fi

    read_pidstat_file $file \
        | awk '{ print $1,$8,$9,$10,$11 }' \
        | tr ' ' ','
}



function parse_sar_network() {
    # This script reads a sar sadf file and outputs a CSV file
    params=$(get_safe_params $@)
    file=$(echo $params | cut -d ' ' -f 1)
    quiet=$(echo $params | cut -d ' ' -f 2)
    if [[ "$quiet" == "false" ]]; then
        echo "iface,rxpck/s,txpck/s,rxkB/s,txkB/s"
    fi

    sadf -d $file -- -n DEV \
        | tail -n +2 \
        | awk 'BEGIN{FS=";"} {print $4,$5,$6,$7,$8}' \
        | tr ',' '.' \
        | tr ' ' ','
}

function parse_sar_cpu() {
    # This script reads a sar sadf file and outputs a CSV file
    params=$(get_safe_params $@)
    file=$(echo $params | cut -d ' ' -f 1)
    quiet=$(echo $params | cut -d ' ' -f 2)
    if [[ "$quiet" == "false" ]]; then
        echo "core,usr,kernel,softirq,idle"
    fi

    sadf -d $file -- -u ALL -P ALL \
        | tail -n +2 \
        | awk 'BEGIN{FS=";"} {print $4,$5,$7,$11,$14}' \
        | tr ',' '.' \
        | tr ' ' ','
}
