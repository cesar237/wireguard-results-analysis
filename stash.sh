#!/bin/bash

# Regarder les buffer sizes dans la configuration de la stack réseau pour optimiser les perfs
look at 
sysctl net.core.rmem_max = 67108864
sysctl net.core.wmem_max = 67108864
sysctl net.ipv4.udp_rmem_min = 16384
sysctl net.ipv4.udp_wmem_min = 16384
sysctl net.ipv4.udp_mem = 1516824  1011219  4194304
sysctl net.core.netdev_budget_usecs = 4000

mkdir -p summary
algos="rr sh dh lc nq"
for algo in $algos; do  
    pidstat_to_csv server/results/nflow-100/algo-$algo/pidstat.log | sed "s/^/$algo,/" >> summary/pidstat.csv;
done

for algo in $algos; do 
    compute_metrics clients/gros-86/results/nflow-100/algo-$algo | sed "s/^/$algo,/" >> summary/sock.csv;
done



batches="2 4 8 16"
for batch in $batches; do 
    echo -n $batch, >> summary/pidstat.csv; 
    pidstat_to_csv server/results/nflow-100/batch-$batch/ring-1/pidstat.log | sed "s/^/$batch,/" >> summary/pidstat.csv;
done

batches="2 4 8 16"
for batch in $batches; do 
    echo -n $batch, >> summary/pidstat.csv; 
    pidstat_to_csv server/results/nflow-100/batch-$batch/ring-1/pidstat.log | sed "s/^/$batch,/" >> summary/pidstat.csv;
done

rings="2 4 8 18"
mkdir -p summary
for ring in $rings; do 
    echo -n $ring, >> summary/pidstat.csv; 
    pidstat_to_csv server/results/nflow-100/batch-1/ring-$ring/pidstat.log | sed "s/^/$ring,/" >> summary/pidstat.csv;
done

for ring in $rings; do 
    echo -n $ring, >> summary/sock.csv; 
    compute_metrics clients/gros-98/results/nflow-100/batch-1/ring-$ring/ | sed "s/^/$ring,/" >> summary/sock.csv;
done


mkdir -p summary
pidstat_to_csv server/results/nflow-100/pidstat.log >> summary/pidstat.csv;
compute_metrics clients/gros-98/results/nflow-100/  >> summary/sock.csv;

pidstatfile=server/results/run-1/CPU-18/nflow-100/pidstat/pidstat.data
cat $pidstatfile \
    | grep kworker \
    | grep wg \
    | awk '{ print $NF }' \
    | sort | uniq | wc -l

function nr_unique_wg_workers() {
    nclient=$1
    pidstatfile=server/results/run-1/CPU-18/nflow-$nclient/pidstat/pidstat.data
    cat $pidstatfile \
        | grep kworker \
        | grep wg \
        | awk '{ print $NF }' \
        | sort | uniq | wc -l
}

for b in 2 4 8 16 32; do 
    for c in 4 16 32; do
        target=batch-$b/concurrency-$c 
        echo "moving $target..."
        location=`find old | grep -E "$target$"`
        ls $location
        cp -r $location/CPU-18 $target/run-1
    done; 
done

mkdir -p {batch-2,batch-4,batch-8,batch-16,batch-32}

# Pour chaque dossier batch, créer les dossiers de concurrence
for batch in batch-*; do
    mkdir -p "$batch"/{concurrency-4,concurrency-16,concurrency-32}/run-1
done


file=out.svg
function count_samples(){
    file=$1
    funcname=$2

    grep "$funcname" $file | tr -d '(,' | cut -d ' ' -f 2 | paste -sd+ | bc
}
total=$(count_samples $file "<title>all ")
decrypt_worker=$(count_samples $file wg_packet_decrypt_worker)
encrypt_worker=$(count_samples $file wg_packet_encrypt_worker)
encrypt_packet=$(count_samples $file encrypt_packet)
decrypt_packet=$(count_samples $file decrypt_packet)
spinlock=$(count_samples $file raw_spin)

echo $total,$encrypt_worker,$decrypt_worker,$encrypt_packet,$decrypt_packet,$spinlock