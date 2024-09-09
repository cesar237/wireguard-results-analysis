#! /bin/bash


if [ -z "$1" ]; then
    echo "Please put a node path here..."
    exit 1
else
    run_dir=$1
fi
curr=`pwd`

cd $run_dir/results

echo "cpu,client,node,run,data,throughput,retransmissions,congestion_window"

for run in `ls`; do
    nrun=$(echo $run | cut -d- -f2)

    for cpu in $(ls $run | grep CPU); do
        ncpu=$(echo $cpu | cut -d "-" -f 2)

        for flow in $(ls $run/$cpu); do
            nflow=$(echo $flow | cut -d "-" -f 2)

            for node in `seq 1 $nflow`; do
                tail -n +4 $run/$cpu/$flow/iperf3-$node.log \
                        | head -n -5 \
                        | awk -v cpu=$ncpu -v flow=$nflow -v run=$nrun -v node=$node '{ print cpu,flow,node,run,$5,$7,$9,$10 }' \
                        | tr ' ' ','
            done
        done
    done
done

cd $curr