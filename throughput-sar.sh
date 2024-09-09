#! /bin/bash


if [ -z "$1" ]; then
    echo "Please put a run_dir path here..."
    exit 1
else
    run_dir=$1
fi
curr=`pwd`

cd $run_dir/results

echo "cpu,client,run,iface,rxpck/s,txpck/s,rxkB/s,txkB/s"


for run in $(ls); do
    nrun=$(echo $run | cut -d- -f2)

    for cpu in $(ls $run | grep CPU); do
        ncpu=$(echo $run/$cpu | cut -d "-" -f3)

        for flow in $(ls $run/$cpu); do
            nflow=$(echo $flow | cut -d "-" -f 2)

            sadf -d $run/$cpu/$flow/sar/sar.data -- -n DEV \
                | tail -n +2 \
                | awk -v cpu=$ncpu -v flow=$nflow -v run=$nrun 'BEGIN{FS=";"} {print cpu,flow,run,$4,$5,$6,$7,$8}' \
                | tr ',' '.' \
                | tr ' ' ','
        done
    done
done

cd $curr