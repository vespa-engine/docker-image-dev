#!/bin/sh
# Copyright Verizon Media. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Build baseline base image for running vespa system tests using docker swarm.

DEVIMAGE=vespaengine/vespa-dev-centos7

CONTAINER_NAME=$USER-build-vespanode-baselinebase-centos7
BASELINEBASE_NAME=$USER-vespanode-baselinebase-centos7

docker stop $CONTAINER_NAME
docker container rm $CONTAINER_NAME

if docker run \
	  --name $CONTAINER_NAME \
	  --env RUBYLIB=/home/$USER/git/system-test/lib:/home/$USER/git/system-test/tests \
	  --env USER=$USER \
	  --env VESPA_HOME=/home/$USER/vespa \
	  --env VESPA_SYSTEM_TEST_HOME=/home/$USER/git/system-test \
	  --env VESPA_SYSTEM_TEST_USE_TLS=true \
	  --env VESPA_USER=$USER \
	  $DEVIMAGE \
	  bash -cxe "(groupadd -g $(id -g) $(id -gn) || true) && useradd -M -g $(id -g) -u $(id -u) -c 'vespanode user' $USER && mkdir /home/$USER && chown $(id -u):$(id -g) /home/$USER && echo '$USER ALL=(ALL) NOPASSWD: ALL' >>/etc/sudoers"
then
    echo "Created user $USER"
    docker commit --change "USER $USER" --change "WORKDIR /home/$USER" $CONTAINER_NAME $BASELINEBASE_NAME
else
    echo "Failed creating user $USER" 1>&2
    exit 1
fi
docker container rm $CONTAINER_NAME
