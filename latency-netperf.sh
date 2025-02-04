#! /bin/bash


if [ -z "$1" ]; then
    echo "Please put a node path here..."
    exit 1
else
    run_dir=$1
fi
curr=`pwd`

cd $run_dir/results

echo "cpu,client,node,run,min,mean,median,90th,99th,max,std"

for run in `ls`; do
    nrun=$(echo $run | cut -d- -f2)
    for cpu in $(ls $run | grep CPU); do
        ncpu=$(echo $cpu | cut -d "-" -f 2)
        for flow in $(ls $run/$cpu); do
            nflow=$(echo $flow | cut -d "-" -f 2)
            for node in `seq 1 $nflow`; do
                idx="$ncpu,$nflow,$node,$nrun"
                data=$(tail -n 1 $run/$cpu/$flow/sar/netperf_rr_$node.log)
                if [ -n "$data" ]; then
                    echo $idx,$data
                fi        
            done
        done
    done
done

cd $curr