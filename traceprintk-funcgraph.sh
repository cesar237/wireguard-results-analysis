#! /bin/bash


if [ -z "$1" ]; then
    echo "Please put a node path here..."
    exit 1
else
    run_dir=$1
fi
curr=`pwd`

cd $run_dir/results

echo "cpu,client,run,core,timestamp,function,depth,calltime,rettime"

for run in `ls`; do
    nrun=$(echo $run | cut -d- -f2)

    for cpu in $(ls $run | grep CPU); do
        ncpu=$(echo $cpu | cut -d "-" -f 2)

        for flow in $(ls $run/$cpu); do
            nflow=$(echo $flow | cut -d "-" -f 2)

            trace-cmd report -R -i $run/$cpu/$flow/trace-printk/trace.dat \
                | grep funcgraph_exit \
                | tr "=[]" " " \
                | tr -d ":" \
                | awk -v cpu=$ncpu -v flow=$nflow -v run=$nrun '{ print cpu,flow,run,$2,$3,$6,$8,$12,$14 }' \
                | tr ' ' ',' 
        done
    done
done

cd $curr