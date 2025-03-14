#! /bin/bash


if [ -z "$1" ]; then
    echo "Please put a run_dir path here..."
    exit 1
else
    run_dir=$1
fi
curr=`pwd`

cd $run_dir

echo "timestamp,wait,used,core,command"

# One-liner to read cleaned pidstat file
# cat pidstat.data | grep -vE "^$|\%usr|grid5000" | less

# One-liner to read "only wg processes" in pidstat file
# cat pidstat.data | grep -E "wg|ksoftirqd" | less 

function read_pidstat_file() {
    file=$1
    cat $file | grep -vE "^$|\%usr|grid5000|Average"
}

for run in $(ls); do
    nrun=$(echo $run | cut -d- -f2)

    for cpu in $(ls $run | grep CPU); do
        ncpu=$(echo $run/$cpu | cut -d "-" -f3)

        for flow in $(ls $run/$cpu); do
            nflow=$(echo $flow | cut -d "-" -f 2)

            file=$run/$cpu/$flow/pidstat/pidstat.data
            read_pidstat_file $file \
                | awk -v cpu=$ncpu -v flow=$nflow -v run=$nrun '{ print cpu,flow,run,$1,$8,$9,$10,$11 }' \
                | tr ' ' ','
        done
    done
done

cd $curr