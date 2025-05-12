#!/bin/bash

prefix=benchmark-wireguard

# vanilla
pushd $prefix-vanilla
parse_vanilla
popd

# noqueue
pushd $prefix-no-queue
parse_vanilla
popd

# batch
pushd $prefix-batch
parse_batches
popd

# mq
pushd $prefix-multi-queue-pool
parse_mq
popd

# mq-steering
pushd $prefix-multi-queue-pool-steering
parse_mq
popd