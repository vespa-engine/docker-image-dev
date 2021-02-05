#!/bin/sh
# Copyright Verizon Media. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

rm -rf systemtests-swarm
mkdir -p systemtests-swarm

NUMNODES=1
SERVICE_CONSTRAINT="--service-constraint node.labels.enable-$USER-vespanode==true"
SERVICE_RAMDISK="--service-ramdisk"
SERVICE_RESERVE_MEMORY="--service-reserve-memory 6GB"
TEST_SELECTION="--file search/basicsearch/basic_search.rb"

$HOME/git/system-test/bin/run-tests-on-swarm.sh -i $USER-vespanode-centos7 -n $NUMNODES $SERVICE_CONSTRAINT --service-init $SERVICE_RAMDISK $SERVICE_RESERVE_MEMORY --resultdir $(pwd)/systemtests-swarm -c -d 5 $TEST_SELECTION
