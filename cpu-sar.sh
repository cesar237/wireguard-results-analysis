#! /bin/bash


if [ -z "$1" ]; then
    echo "Please put a run_dir path here..."
    exit 1
else
    run_dir=$1
fi
curr=`pwd`

cd $run_dir/results

echo "cpu,client,run,core,usr,kernel,softirq,idle"

for run in $(ls); do
    nrun=$(echo $run | cut -d- -f2)

    for cpu in $(ls $run | grep CPU); do
        ncpu=$(echo $run/$cpu | cut -d "-" -f 3)

        for flow in $(ls $run/$cpu); do
            nflow=$(echo $flow | cut -d "-" -f 2)

            sadf -d $run/$cpu/$flow/sar/sar.data -- -u ALL -P ALL \
            | tail -n +2 \
            | awk -v cpu=$ncpu -v flow=$nflow -v run=$nrun 'BEGIN{FS=";"} {print cpu,flow,run,$4,$5,$7,$11,$14}' \
            | tr ',' '.' \
            | tr ' ' ','
        done
    done

done

cd $curr