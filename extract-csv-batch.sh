#! /usr/bin/bash


if [ -z "$1" ]; then
    echo "Please provide a result directory... format: results-XXXXXX"
    exit -1;
else
    res_dir=$1
fi

current=`cat $res_dir/EXPERIMENT_DATA/CURRENT_EXP`
kind=`cat $res_dir/EXPERIMENT_DATA/$current.yaml | grep throughput_test | awk '{ print $2 }'`


curr=`pwd`
cd $res_dir;

# Get server's CPU usage with SAR
echo "Extracting server data..."

for batch in 2 4 8 16 32; do
for concurrency in 4 16 32; do

resdir=summary/batch-$batch/concurrency-$concurrency

mkdir -p $resdir/server

# Get server's CPU usage with PIDSTAT
$curr/cpu-pidstat.sh server/results/batch-$batch/concurrency-$concurrency > $resdir/server/cpu-pidstat.csv
echo "Done!"

# Get server's throughput
$curr/throughput-sar.sh server/results/batch-$batch/concurrency-$concurrency > $resdir/server/throughput-sar.csv

# Get server's CPU usage
$curr/cpu-sar.sh server/results/batch-$batch/concurrency-$concurrency > $resdir/server/cpu-sar.csv
echo "Done!"

# # Get server's CPU usage
# $curr/cpu-pidstat.sh server > summary/server/cpu-pidstat.csv
# echo "Done!"

# # Get clients' data
# echo "Extracting clients' data..."
# mkdir -p summary/clients

# if [[ "$kind" == "IPERF3" ]]; then
#     # Get clients latency
#     echo "Extracting latencies..."
#     i=0
#     for node in $(ls clients/); do
#         i=$(( i+1 ))
#         $curr/latency-netperf.sh clients/$node > summary/clients/latency-$i.csv
#     done
#     echo "Done!"

#     # Get clients throughput
#     echo "Extracting throughput..."
#     i=0
#     for node in $(ls clients/); do
#         i=$(( i+1 ))
#         $curr/throughput-iperf.sh clients/$node > summary/clients/throughput-$i.csv
#     done
#     echo "Done!"
# fi

# if [[ "$kind" == "SOCKPERF" ]]; then
    # Get clients sockperf latency
echo "Extracting sockperf-latency metrics..."
mkdir -p $resdir/clients
i=0
for node in $(ls clients/); do
    i=$(( i+1 ))
    $curr/latency-sockperf.sh clients/$node/results/batch-$batch/concurrency-$concurrency > $resdir/clients/sockperf-$i-.csv
    cat $resdir/clients/sockperf-$i-.csv | grep -v ppsforoldcompatibility > $resdir/clients/sockperf-$i.csv
done
echo "Done!"
# fi

done 
done