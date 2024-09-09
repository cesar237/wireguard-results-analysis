#! /usr/bin/bash

function list_all_tests() {
    for i in `ls | grep results-`; do
        echo -n "$i: "
	cat $i/EXPERIMENT_DATA/TEST_CONFIG
    done
}

function check_analyzed_tests() {
    for i in `ls | grep results-`; do
        echo "$i: "
	echo "TEST_CONFIG: $(cat $i/EXPERIMENT_DATA/TEST_CONFIG)"
	echo -n "Analysed: "
	if [ -z "$(ls $i | grep summary)" ]; then
            echo "No"
	else
            echo "Yes"
	fi
	echo
    done
}
