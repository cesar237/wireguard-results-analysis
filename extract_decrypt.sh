#! /usr/bin/bash

# to sum: awk '{s+=$1} END {print s}' mydatafile

function extract_from_flamegraph() {
    # $1 is the flamegraph file
    # $2 is the function to look at
    name=$(echo $1 | cut -d. -f1)
    run=$(echo $name | cut -d- -f2)
    clients=$(echo $name | cut -d- -f4)

    echo -n $(cat $1 | grep $2 \
        | cut -d% -f 1 \
        | awk '{print $NF}' \
        | awk '{s+=$1} END {print s}')
}

maindir=$1

for resdir in `ls $maindir`; do
# resdir="results-1e68e038"
prefix=$maindir/$resdir/flamegraphs
output=$maindir/$resdir/summary/decrypt_time.csv

echo run,clients,decrypt_worker,decrypt_packet,spin_lock,idle > $output

for f in `ls $prefix`; do
    name=$(echo $f | cut -d. -f1)
    run=$(echo $name | cut -d- -f2)
    clients=$(echo $name | cut -d- -f4)

    decrypt=$(extract_from_flamegraph $prefix/$f decrypt_packet)
    spin=$(extract_from_flamegraph $prefix/$f raw_spin_lock_bh)
    worker=$(extract_from_flamegraph $prefix/$f wg_packet_decrypt_worker)
    idle=$(extract_from_flamegraph $prefix/$f swapper)

    echo $run,$clients,$worker,$decrypt,$spin,$idle >> $output
done

done