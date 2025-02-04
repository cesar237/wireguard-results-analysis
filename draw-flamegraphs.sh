#! /usr/bin/bash

function draw_flamegraph() {
    if [ -z $1 ]; then  
        echo "give a perf file please"
        return
    else
        FILE=$1
    fi
    stackcollapse-perf.pl $FILE > $FILE.folded
    flamegraph.pl $FILE.folded
}

if [ -z "$1" ]; then
	echo "Please give me a result directory..."
	exit 1
else
	res_dir=$1
fi

cd $res_dir
mkdir -p flamegraphs
flamegraphs_dir=$(pwd)/flamegraphs

cd server/results

# Go in all CPUs and flows:
for run in `ls`; do
    nrun=$(echo $run | cut -d- -f2)
    for cpu in $(ls $run | grep CPU); do
        ncpu=$(echo $cpu | cut -d "-" -f 2)
        for flow in $(ls $run/$cpu); do
            nflow=$(echo $flow | cut -d "-" -f 2)
            prefix=$run/$cpu/$flow/perf
            draw_flamegraph $prefix/out.perf > $flamegraphs_dir/flamegraph-$nrun-$ncpu-$nflow.svg
        done
    done
done

cd ../../../