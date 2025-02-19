#! /usr/bin/bash


if [ -z "$1" ]; then
    echo "Please provide a result directory... format: results-XXXXXX"
    exit -1;
else
    res_dir=$1
fi

curr=`pwd`
cd $res_dir;

# Get server's data
echo "Extracting server data..."
mkdir -p summary/server

# Get server's throughput
$curr/throughput-sar.sh server > summary/server/throughput-sar.csv

# Get server's CPU usage
$curr/cpu-sar.sh server > summary/server/cpu-sar.csv
echo "Done!"

# Get server's CPU usage
$curr/cpu-pidstat.sh server > summary/server/cpu-pidstat.csv
echo "Done!"

# Get traceprintk data
echo "Extracting traceprintk data..."
$curr/traceprintk-funcgraph.sh server > summary/server/traceprintk.csv
echo "Done!"

# Get clients' data
echo "Extracting clients' data..."
mkdir -p summary/clients

# # Get clients latency
# echo "Extracting latencies..."
# i=0
# for node in $(ls clients/); do
#     i=$(( i+1 ))
#     $curr/latency-netperf.sh clients/$node > summary/clients/latency-$i.csv
# done
# echo "Done!"

# # Get clients throughput
# echo "Extracting throughput..."
# i=0
# for node in $(ls clients/); do
#     i=$(( i+1 ))
#     $curr/throughput-iperf.sh clients/$node > summary/clients/throughput-$i.csv
# done
# echo "Done!"

# Get clients sockperf latency
echo "Extracting sockperf-latency metrics..."
i=0
for node in $(ls clients/); do
    i=$(( i+1 ))
    $curr/latency-sockperf.sh clients/$node > summary/clients/sockperf-$i.csv
done
echo "Done!"
