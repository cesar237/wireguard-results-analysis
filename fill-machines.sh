#! /usr/bin/bash

echo "Filling machine types of all results..."
for res_dir in `ls | grep results-`; do
	machine=$(cat $res_dir/EXPERIMENT_DATA/SERVER | cut -d- -f1)
	echo $machine > $res_dir/EXPERIMENT_DATA/MACHINE_TYPE
done
echo Done!
