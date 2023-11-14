#!/bin/sh -ex
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Build image for running vespa system tests using docker swarm and vespa install tree from dev image.

VOLUME=
buildmode=normal

args=`getopt m:v: $*`
if [ $? -ne 0 ]; then
    echo "Usage: build-vespanode.sh [-m (normal|baseline|fixup)] [-v homevolume]" 1>&2
    exit 1
fi
set -- $args
while :; do
    case "$1" in
	-v) VOLUME=$2; shift; shift;;
	-m) case "$2" in
	    normal|fixup|baseline) buildmode=$2; shift; shift;;
	    *) echo "Wrong argument to -m option, expected normal, baseline or fixup" 1>&2
	       exit 1;;
	    esac;;
	--) shift; break;;
    esac
done

if test $# -gt 0
then
    echo "Unexpected remaining arguments: $*" 1>&2
    exit 1
fi

. $(dirname $0)/vespanode-common.sh

if test -z "$VOLUME"
then
    VOLUME=$VESPA_DEV_VOLUME
fi

case "$VOLUME" in
    /*) if test -d $VOLUME -a -d $VOLUME/git/system-test -a -d $VOLUME/bin -a -d $VOLUME/vespa
	then
	    :
	else
	    echo "Cannot find vespa or system tests" 1>&2
	    exit 1
	fi;;
    *)  VOLUMELIST=$(docker volume ls -q)
	found=false
	for v in ${VOLUMELIST}
	do
	    test $v = $VOLUME && found=true
	done
	if $found
	then
	    :
	else
	    echo "Cannot find volume $VOLUME" 1>&2
	    exit 1
	fi;;
esac

DOCKER_IMAGE=$USER-vespanode-baselinebase-centos-stream8
DOCKER_NEW_IMAGE=$USER-vespanode-centos-stream8
case $buildmode in
    baseline) DOCKER_NEW_IMAGE=$USER-vespanode-baseline-centos-stream8 ;;
    fixup) DOCKER_IMAGE=$USER-vespanode-baseline-centos-stream8 ;;
esac

BUILD_CONTAINER_NAME=$USER-build-vespanode-centos-stream8-$$

echo "Making vespanode image"

docker stop $BUILD_CONTAINER_NAME || true
docker container rm $BUILD_CONTAINER_NAME || true

if docker run \
  --name $BUILD_CONTAINER_NAME \
  -v ${VOLUME}:/mnt \
  -v $(pwd):/mnt2 \
  ${DOCKER_IMAGE} \
  /mnt2/build-vespanode-in-container.sh
then
  echo "Made vespanode image"
  docker commit \
	 --change "ENV VESPA_TLS_CONFIG_FILE=/home/$USER/vespa/conf/vespa/tls/tls_config.json" \
	 --change 'CMD [ "bash", "-lc", "bin/run-vespanode.sh" ]' \
	 $BUILD_CONTAINER_NAME $DOCKER_NEW_IMAGE
else
  echo "Failed creating vespanode image"
fi
docker container rm $BUILD_CONTAINER_NAME
