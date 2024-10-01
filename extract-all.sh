#! /usr/bin/bash

if [ -z $1 ]; then
	echo "Please give the site from which we retreive the results..."
	echo "Usage: extract-all.sh <site>"
	echo "Example: extract-all.sh nancy"
	exit -1
else
	site=$1
fi

if [ -z $2 ]; then
	variant=""
else
	variant=$2
fi

# Retrieve data from site
rsync -zvr $site.g5k:wireguard-experiment/results/${variant}results-* results

for i in `ls results`; do
	if [ -d "$i" ]; then
		echo "Result file already there. Skip..."
	else
		echo "Copy results to working directory..."
		cp -r results/$i .
	fi
done

# Record the site the results come from and
# Decompress all results directories
for i in `ls | grep results-`; do
	zst_files=$(find $i -iname *.zst);
	if [ -z "$zst_files" ]; then
		echo "$i is already decompressed!";
	else
		echo "$i should be decompressed...";
		./decompress-results.sh $i;
	fi;

	echo $site > $i/EXPERIMENT_DATA/SITE
done

# Analyze all results directories
for i in `ls | grep results-`; do
	if [ -n "$(ls $i | grep summary)" ]; then
		echo "Result directory already analysed. Skip..."
	else
		./extract-csv.sh $i
	fi
done
