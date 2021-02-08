#!/bin/sh -ex
# Copyright Verizon Media. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

DOCKER_IMAGE=$1
TUNNELED_REGISTRY=$2
if test -z "$TUNNELED_REGISTRY"
then
    # No tunneling, use local registry
    . $(dirname $0)/vespanode-common.sh
    TUNNELED_REGISTRY=$LOCAL_REGISTRY
fi
echo "Downloading vespanode image ${DOCKER_IMAGE} on $(hostname)"
docker pull ${TUNNELED_REGISTRY}/${DOCKER_IMAGE}
docker tag ${TUNNELED_REGISTRY}/${DOCKER_IMAGE} ${DOCKER_IMAGE}
docker image rm ${TUNNELED_REGISTRY}/${DOCKER_IMAGE}
