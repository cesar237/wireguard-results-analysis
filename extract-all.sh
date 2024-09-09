#! /usr/bin/bash

# Retrieve data from nancy
rsync -zvr nancy.g5k:wireguard-experiment/results .

for i in `ls results`; do
	if [ -d "$i" ]; then
		echo "Result file already there. Skip..."
	else
		echo "Copy results to working directory..."
		cp -r results/$i .
	fi
done

# Decompress all results directories
for i in `ls | grep results-`; do
	zst_files=$(find $i -iname *.zst);
	if [ -z "$zst_files" ]; then
		echo "$i is already decompressed!";
	else
		echo "$i should be decompressed...";
		./decompress-results.sh $i;
	fi;
done

# Analyze all results directories
for i in `ls | grep results-`; do
	if [ -n "$(ls $i | grep summary)" ]; then
		echo "Result directory already analysed. Skip..."
	else
		./extract-csv.sh $i
	fi
done
