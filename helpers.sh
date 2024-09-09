#! /usr/bon/bash

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
