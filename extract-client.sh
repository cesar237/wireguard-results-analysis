#! /usr/bin/bash

# Import parser functions
source csv_parsers.sh

if [ -z "$1" ]; then
    echo "Please provide a result directory... format: results-XXXXXX"
    exit -1;
else
    res_dir=$1
fi

current=`cat $res_dir/EXPERIMENT_DATA/CURRENT_EXP`

curr=`pwd`
cd $res_dir;

# Get clients csv results
echo "Extracting client data..."
mkdir -p summary

for node in $(ls clients/); do
    # Move csv files to summary
    cd clients/${node}/results/
    cp *.csv ../../../summary/

    # Get server's CPU usage with pidstat
    echo "Extracting server CPU usage with pidstat..."
    for file in $(ls | grep -E "pidstat"); do
        parse_pidstat $file > ../../../summary/${file}.csv
    done

    # Get server's CPU usage with sar
    echo "Extracting server CPU usage with sar..."
    for file in $(ls | grep -E "sar"); do
        parse_sar_cpu $file > ../../../summary/${file}.cpu.csv
    done

    # Get server's throughput usage
    echo "Extracting server throughput usage with sar..."
    for file in $(ls | grep -E "sar"); do
        parse_sar_network $file > ../../../summary/${file}.net.csv
    done

    cd ../../../
done