#!/bin/sh -x
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

DOCKER_IMAGE=$1
. $(dirname $0)/vespanode-common.sh
echo "Removing vespanode image ${DOCKER_IMAGE} on $(hostname)"
docker image rm ${TUNNELED_REGISTRY}/${DOCKER_IMAGE}
docker image rm ${LOCAL_REGISTRY}/${DOCKER_IMAGE}
docker image rm ${DOCKER_IMAGE}
true
