#! /bin/bash


if [ -z "$1" ]; then
    echo "Please put a node path here..."
    exit 1
else
    run_dir=$1
fi
curr=`pwd`

cd $run_dir/results

echo "cpu,client,node,run,min,median,99th,99.9th,99.99th,99.999th,max"

function get_sockperf_data() {
    file=$1
    line=$2

    data_line=$(tail $file | head -n $line | tail -n 1)
    echo $data_line | awk -F'=' '{print $NF}' | tr -d ' '
}

for run in `ls`; do
    nrun=$(echo $run | cut -d- -f2)
    for cpu in $(ls $run | grep CPU); do
        ncpu=$(echo $cpu | cut -d "-" -f 2)
        for flow in $(ls $run/$cpu); do
            nflow=$(echo $flow | cut -d "-" -f 2)
            for node in `seq 1 $nflow`; do
                idx="$ncpu,$nflow,$node,$nrun"

                # Construct data with data in files of format sockperf_$i.log
                file=$run/$cpu/$flow/sar/sockperf_$node.log
                min=$(get_sockperf_data $file 10)
                median=$(get_sockperf_data $file 8)
                th99=$(get_sockperf_data $file 5)
                th99_9=$(get_sockperf_data $file 4)
                th99_99=$(get_sockperf_data $file 3)
                th99_999=$(get_sockperf_data $file 2)
                max=$(get_sockperf_data $file 1)

                data="$min,$median,$th99,$th99_9,$th99_99,$th99_999,$max"

                if [ -n "$data" ]; then
                    echo $idx,$data
                fi
            done
        done
    done
done

cd $curr
