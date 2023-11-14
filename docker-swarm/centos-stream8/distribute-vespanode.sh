#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

host=$1
DOCKER_IMAGE=$2
. $(dirname $0)/vespanode-common.sh
ssh -a $SSH_REGISTRY_TUNNEL_ARG -o ExitOnForwardFailure=yes $host bash -lc "'git/docker-image-dev/docker-swarm/centos-stream8/download-vespanode.sh $DOCKER_IMAGE $TUNNELED_REGISTRY'"
