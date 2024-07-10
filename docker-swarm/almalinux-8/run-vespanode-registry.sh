#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# docker pull registry:2
if test "$(docker image ls  -f reference=registry:2 | wc -l)" -le 1
then
    echo "registry:2 docker image is missing." 1>&2
    exit 1
fi
. $(dirname $0)/vespanode-common.sh
CONTAINER_NAME=$USER-vespanode-registry
VOLUME_NAME=${CONTAINER_NAME}
docker container stop ${CONTAINER_NAME}
docker container rm ${CONTAINER_NAME}
docker run -d -p ${LOCAL_REGISTRY}:5000 -v ${VOLUME_NAME}:/var/lib/registry --name ${CONTAINER_NAME} registry:2
