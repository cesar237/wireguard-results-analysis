#!/bin/bash

case $1 in 
batch)

for i in 1 25 50 75 100
do
    pushd bench-wg/results-69705835/clients/gros-7/results/batch-$2/concurrency-$3/run-1/CPU-18/nflow-$i/sar

    echo "Debit=[" > a.py
    grep "Valid Duration" *.log | tr '=;' ' ' | awk '{ print ($8 * 8 * 1500 / $5)/(1024*1024),"," }' >> a.py
    echo "]" >> a.py

cat>>a.py<<EOF
print(sum(Debit))
EOF

    python3 a.py

    popd
done

;;

vanilla)

for i in 1 25 50 75 100
do
    pushd bench-wg/results-5d52d559/clients/gros-7/results/run-1/CPU-18/nflow-$i/sar

    echo "Debit=[" > a.py
    grep "Valid Duration" *.log | tr '=;' ' ' | awk '{ print ($8 * 8 * 1500 / $5)/(1024*1024),"," }' >> a.py
    echo "]" >> a.py

cat>>a.py<<EOF
print(sum(Debit))
EOF

    python3 a.py

    popd
done
;;

esac;
# exit