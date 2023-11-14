#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

rm -rf systemtests-swarm
mkdir -p systemtests-swarm

NUMNODES=2
SERVICE_CONSTRAINT="--service-constraint node.labels.enable-$USER-vespanode==true"
SERVICE_RAMDISK="--service-ramdisk"
SERVICE_RESERVE_MEMORY="--service-reserve-memory 6GB"
TEST_SELECTION="--file search/feed_block/feed_block.rb --file search/feed_block/feed_block_disk_two_nodes.rb --file search/feed_block/feed_block_shared_disk_two_nodes.rb"

$HOME/git/system-test/bin/run-tests-on-swarm.sh -i $USER-vespanode-centos7 -n $NUMNODES $SERVICE_CONSTRAINT $SERVICE_RAMDISK $SERVICE_RESERVE_MEMORY --resultdir $(pwd)/systemtests-swarm -c -d 5 $TEST_SELECTION
