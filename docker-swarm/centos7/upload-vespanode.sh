#!/bin/sh -ex
# Copyright Verizon Media. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

DOCKER_IMAGE=$1
. $(dirname $0)/vespanode-common.sh
echo "Uploading vespanode image ${DOCKER_IMAGE} on $(hostname)"
docker tag ${DOCKER_IMAGE} ${LOCAL_REGISTRY}/${DOCKER_IMAGE}
docker push ${LOCAL_REGISTRY}/${DOCKER_IMAGE}
docker image rm ${LOCAL_REGISTRY}/${DOCKER_IMAGE}
