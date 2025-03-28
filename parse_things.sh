#! /bin/bash

function parse_vanilla() {
    client=`ls clients`
    nflows="100"
    rm -rf summary
    mkdir  -p summary

    for i in $nflows; do
        # Get throughput and latency
        compute_metrics clients/$client/results/nflow-$i/ > summary/sock-$i.csv
        # Get CPU
        pidstat_to_csv server/results/nflow-$i/pidstat.log > summary/cpu-$i.csv


        # Get Flamegraphs
        draw_flamegraph server/results/nflow-$i/out.perf > summary/$i.svg
        decrypt_worker=$(flamegraph_sum_samples summary/$i.svg decrypt_worker)
        decrypt_packet=$(flamegraph_sum_samples summary/$i.svg ">chacha20poly1305")
        spinlock=$(flamegraph_sum_samples summary/$i.svg raw_spin_lock)
        echo $decrypt_worker,$decrypt_packet,$spinlock > summary/wg-$i.csv

        # Get microstats
        perf_stats server/results/nflow-$i > summary/micro-$i.csv
    done
}


function parse_batches() {
    client=`ls clients`
    nflows="100"
    rings="2 4 8 18"
    batches="2 4 8 16"
    rm -rf summary
    mkdir  -p summary

    for i in $nflows; do
    for b in $batches; do
        resdir=summary/batch-$b/ring-1
        input_dir=results/nflow-$i/batch-$b/ring-1
        mkdir -p $resdir
        # Get throughput and latency
        compute_metrics clients/$client/$input_dir > $resdir/sock-$i.csv
        # Get CPU
        pidstat_to_csv server/$input_dir/pidstat.log > $resdir/cpu-$i.csv


        # Get Flamegraphs
        draw_flamegraph server/$input_dir/out.perf > $resdir/$i.svg
        decrypt_worker=$(flamegraph_sum_samples $resdir/$i.svg decrypt_worker)
        decrypt_packet=$(flamegraph_sum_samples $resdir/$i.svg ">chacha20poly1305")
        spinlock=$(flamegraph_sum_samples $resdir/$i.svg raw_spin_lock)
        echo $decrypt_worker,$decrypt_packet,$spinlock > $resdir/wg-$i.csv

        # Get microstats
        perf_stats server/$input_dir > $resdir/micro-$i.csv
    done
    done
}

function parse_mq() {
    client=`ls clients`
    nflows="100"
    rings="2 4 8 18"
    rm -rf summary
    mkdir  -p summary

    for i in $nflows; do
    for r in $rings; do
        resdir=summary/batch-1/ring-$r
        input_dir=results/nflow-$i/batch-1/ring-$r
        mkdir -p $resdir
        # Get throughput and latency
        compute_metrics clients/$client/$input_dir > $resdir/sock-$i.csv
        # Get CPU
        pidstat_to_csv server/$input_dir/pidstat.log > $resdir/cpu-$i.csv


        # Get Flamegraphs
        draw_flamegraph server/$input_dir/out.perf > $resdir/$i.svg
        decrypt_worker=$(flamegraph_sum_samples $resdir/$i.svg decrypt_worker)
        decrypt_packet=$(flamegraph_sum_samples $resdir/$i.svg ">chacha20poly1305")
        spinlock=$(flamegraph_sum_samples $resdir/$i.svg raw_spin_lock)
        echo $decrypt_worker,$decrypt_packet,$spinlock > $resdir/wg-$i.csv

        # Get microstats
        perf_stats server/$input_dir > $resdir/micro-$i.csv
    done
    done
}