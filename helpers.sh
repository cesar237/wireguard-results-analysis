#!/usr/bin/bash

function flamegraph_sum_samples() {
	# $1 is the file to look at
	# $2 is the function of interest
	cat $1 | grep $2 | cut -d "%" -f1 | cut -d" " -f 4 | awk '{s+=$1} END {print s}'
}

function decompress_all() {
	for res_dir in `ls results | grep results-`; do
		if [ -d $res_dir ]; then
			echo $res_dir already copied! Skipping...
		else
			cp -r results/$res_dir .
		fi
		if [ -d $res_dir/server/results.tar.zst ]; then
			echo Decompressing $res_dir...
			./decompress_results.sh $res_dir
		fi
		echo $res_dir decompressed!
	done
}

function check_if_decompressed() {
	for res_dir in `ls | grep results-`; do
		echo -n "$res_dir: ";
		if [ -n "$(find $res_dir -iname *.zst)" ]; then
			echo Needs decompression...
		else
			echo Already decompressed!
		fi
	done
}

function decompress_folder() {
	directory=$1
	if [ -z $1 ]; then
		echo "Usage: decompress_folder <directory>"
	fi
	for res in `ls $directory`; do
		./decompress-results.sh $directory/$res
	done
}

function draw_flamegraph_folder() {
	directory=$1
	if [ -z $1 ]; then
		echo "Usage: draw_flamegraph_folder <directory>"
	fi
	for res in `ls $directory`; do
		./draw-flamegraphs.sh $directory/$res
	done
}

function median() {
	sort -n | awk '
		BEGIN {c=0}
		{nums[c++]=$1}
		END {
			if (c%2==0) print (nums[int(c/2)-1]+nums[int(c/2)])/2;
			else print nums[int(c/2)]
		}
	'
}

function median() {
	sort -n | awk '
		BEGIN {c=0}
		{nums[c++]=$1}
		END {
			if (c%2==0) print (nums[int(c/2)-1]+nums[int(c/2)])/2;
			else print nums[int(c/2)]
		}
	'
}

function sum() {
    paste -sd+ | bc
}

function compute_metrics(){
    path=$1
    pushd $path > /dev/null
    # echo -n Bandwidth=
    bw=$(grep "BandWidth" *.log | tr -d '('  | awk '{ print $(NF-1) }' | sum )
    # echo -n Tail Latency=
    latency=$(grep "99.000" *.log | awk '{ print $NF }' | median)
	echo "$bw,$latency"
    popd > /dev/null
}

function read_pidstat_file() {
    file=$1
    cat $file | grep -vE "^$|\%usr|grid5000|Average"
}

function pidstat_to_csv(){
	file=$1
	read_pidstat_file $file \
	| awk '{ print $1,$8,$9,$10,$11 }' \
	| tr ' ' ','
}

function rename_dirs(){
	resdir=$1
	new_name=$(cat $resdir/EXPERIMENT_DATA/CURRENT_EXP)
	mv $resdir $new_name
}

function get_throughput_sockperf() {
	dir_=$1
	grep "Valid Duration" $dir_/*.log | tr '=;' ' ' | awk '{ print ($8 * 8 * 1500 / $5)/(1024*1024) }' | paste -sd+ | bc
}

function get_mean_latency_sockperf() {
	dir_=$1
	# grep "Summary" $dir_/*.log | cut -d ' ' -f5 | awk '{ sum += $1 } END { print sum/NR }'
	grep "Summary" $dir_/*.log | cut -d ' ' -f5 | median
}

function get_percentile_latency_sockperf() {
	dir_=$1
	percentile=$2
	grep "percentile $percentile" $dir_/*.log  | awk '{ print $NF }' | median
}

function get_mean_latency_sockperf() {
	dir_=$1
	value=`grep "Summary" $dir_/*.log | cut -d ' ' -f5 | awk '{ sum += $1 } END { print sum/NR }'`
	echo "Got: $value"
	if [[ "$value" =~  ^[0-9]+([.][0-9]+)?$ ]]; then
		echo $value
	else
		echo 
	fi
}

function get_all_throughput() {
	resdir=$1
	client_node=`ls $resdir/clients`
	rpath=$resdir/clients/$client_node/results/run-1/CPU-18

	echo clients,throughput

	for nflow in `ls $rpath`; do
		client=`echo $nflow | cut -d'-' -f2`
		# echo $rpath/$nflow/sar
		echo -n "$client,"
		value=`get_throughput_sockperf $rpath/$nflow/sar`
		if [ -z "$value" ]; then
			value=" "
		fi
		echo $value
	done
}

function get_all_throughput_batch() {
	resdir=$1
	client_node=`ls $resdir/clients`
	rpath=$resdir/clients/$client_node/results/run-1

	echo clients,batch,concurrency,throughput

	for batch in `ls $rpath`; do
		nbatch=`echo $batch | cut -d'-' -f2`
		# echo $batch

		for cc_level in `ls $rpath/$batch`; do
			ncc_level=`echo $cc_level | cut -d'-' -f2`

			for nflow in `ls $rpath/$batch/$cc_level/CPU-18`; do
				client=`echo $nflow | cut -d'-' -f2`

				echo -n "$client,$nbatch,$ncc_level,"
				value=`get_throughput_sockperf $rpath/$batch/$cc_level/CPU-18/$nflow/sar`
				if [ -z "$value" ]; then
					value=" "
				fi
				echo $value
			done

		done
	done
}

function nr_unique_wg_workers() {
    nclient=$1
    pidstatfile=server/results/run-1/CPU-18/nflow-$nclient/pidstat/pidstat.data
    cat $pidstatfile \
        | grep kworker \
        | grep wg \
        | awk '{ print $NF }' \
        | sort | uniq | wc -l
}

function nr_unique_wg_batch_workers() {
    nclient=$1
	batch=$2
	pidstatfile=server/results/batch-2/concurrency-4/run-1/CPU-18/nflow-100/pidstat/pidstat.data 
    pidstatfile=server/results/run-1/CPU-18/nflow-$nclient/pidstat/pidstat.data
    cat $pidstatfile \
        | grep kworker \
        | grep wg \
        | awk '{ print $NF }' \
        | sort | uniq | wc -l
}

function get_all_latency() {
	resdir=$1
	client_node=`ls $resdir/clients`
	rpath=$resdir/clients/$client_node/results/run-1/CPU-18

	echo clients,median,p99

	for nflow in `ls $rpath`; do
		client=`echo $nflow | cut -d'-' -f2`
		# echo $rpath/$nflow/sar
		echo -n "$client,"
		# mean_value=`get_mean_latency_sockperf $rpath/$nflow/sar`
		median_value=`get_percentile_latency_sockperf $rpath/$nflow/sar 50.00`
		p99_value=`get_percentile_latency_sockperf $rpath/$nflow/sar 99.00`
		if [ -z "$p99_value" ]; then
			p99_value=" "
		fi
		echo $median_value,$p99_value
	done
}

function get_all_latency_batch() {
	resdir=$1
	client_node=`ls $resdir/clients`
	rpath=$resdir/clients/$client_node/results/run-1

	echo clients,batch,concurrency,median,p99

	for batch in `ls $rpath`; do
		nbatch=`echo $batch | cut -d'-' -f2`
		# echo $batch

		for cc_level in `ls $rpath/$batch`; do
			ncc_level=`echo $cc_level | cut -d'-' -f2`

			for nflow in `ls $rpath/$batch/$cc_level/CPU-18`; do
				client=`echo $nflow | cut -d'-' -f2`

				echo -n "$client,$nbatch,$ncc_level,"
				# value=`get_throughput_sockperf $rpath/$batch/$cc_level/CPU-18/$nflow/sar`
				median_value=`get_percentile_latency_sockperf $rpath/$batch/$cc_level/CPU-18/$nflow/sar 50.00`
				p99_value=`get_percentile_latency_sockperf $rpath/$batch/$cc_level/CPU-18/$nflow/sar 99.00`
				if [ -z "$p99_value" ]; then
					p99_value=" "
				fi
				echo $median_value,$p99_value
			done

		done
	done
}

function extract_data_csv() {
	directory=$1
	if [ -z $1 ]; then
		echo "Usage: extract_data_csv <directory>"
	fi
	for res in `ls $directory`; do
		./extract-csv.sh $directory/$res
	done
}

function list_results() { 
	res_dir=$1
	root_dir=~/Documents/Wireguard/results-analysis
	for i in `ls $root_dir/$res_dir`; do
		echo -n "$i: "
		cat $root_dir/$res_dir/$i/EXPERIMENT_DATA/CURRENT_EXP
	done
}

function list_all_tests() {
	i=0
	for res_dir in `ls | grep results-`; do
		i=$(( i+1 ))
		echo -n "$i. $res_dir: "
		cat $res_dir/EXPERIMENT_DATA/TEST_CONFIG
	done
}

function check_if_extracted() {
	i=0
	for res_dir in `ls | grep results-`; do
		i=$((i+1))
		echo -n "$i. $res_dir: "
		if [ -d $res_dir/summary ]; then
			echo YES;
		else
			echo NO;
		fi
	done
}

function extract_all() {
	for res_dir in `ls | grep results-`; do
		if [ -d "$res_dir/summary" ]; then
			echo $res_dir already done. Skipping...
		else
			echo Extracting data from $res_dir...
			./extract-data.sh $res_dir
			echo Done!
		fi
	done
}
