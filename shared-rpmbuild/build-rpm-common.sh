#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

run_container()
{
    # shellcheck disable=SC2086
    $CONTAINER_ENGINE run \
		      -v "$(env pwd):/work" \
		      -v "$(cd ../../.. && env pwd)/shared-rpmbuild:/shared-work" \
		      -v "$SRC_DIR:/src" \
		      --tmpfs /tmp \
		      --tmpfs /var/tmp \
		      --tmpfs /run \
		      $DOCKER_CREATE_ARGS \
		      --hostname "${CONTAINER_HOSTNAME}" \
		      --network "${CONTAINER_NETWORK}" \
		      --name "${CONTAINER_NAME}" \
		      --privileged \
		      "$CONTAINER_FOREGROUND" \
		      --init \
		      "${DOCKER_IMAGE}" \
		      $CONTAINER_COMMAND $1
}

build_rpm_common()
{
    REBUILD_MODE=false
    SPLIT_MODE=false
    unset BUILD_MODE
    unset CONTAINER_COMMAND
    unset CONTAINER_FOREGROUND

    args=$(getopt amrs "$@")
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
	echo "Usage: build-rpm.sh (-a | -m) [-r] [-s] packagename" 1>&2
	exit 1
    fi
    # shellcheck disable=SC2086
    set -- $args
    while :; do
	case "$1" in
	    -a) BUILD_MODE=automatic; shift;;
	    -m) BUILD_MODE=manual; shift;;
	    -r) REBUILD_MODE=true; shift;;
	    -s) SPLIT_MODE=true; shift;;
	    --) shift; break;;
	esac
    done
    package=$1

    case "$package" in
	"")
	    echo "Package not speicified" 1>&2
	    exit 1
	    ;;
	vespa)
	    SRC_DIR=$HOME/git/vespa
	    ;;
	vespa-ann-benchmark)
	    SRC_DIR=$HOME/git/vespa-ann-benchmark
	    ;;
	*)
	    SRC_DIR=$HOME/git/vespa-3rdparty-deps
	    if test -d "$SRC_DIR/$package"
	    then
		:
	    else
		echo "Package $package not found" 1>&2
		exit 1
	    fi
	    ;;
    esac

    case "$BUILD_MODE" in
	automatic)
	    CONTAINER_COMMAND="/work/build-rpm-inner.sh $package"
	    CONTAINER_FOREGROUND="--rm"
	    ;;
	manual)
	    CONTAINER_COMMAND="tail -f /dev/null"
	    CONTAINER_FOREGROUND="-d"
	    REBUILD_MODE=false
	    SPLIT_MODE=false
	    ;;
	*)
	    echo "Must specify -a or -m option" 1>&2
	    exit 1
	    ;;
    esac

    # shellcheck source=../shared/common.sh
    . ../../../shared/common.sh
    # shellcheck disable=2153
    CONTAINER_NAME=rpmbuild-${CONTAINER_SHORTNAME}${CONTAINER_SUFFIX}
    CONTAINER_HOSTNAME=${CONTAINER_NAME}${DOMAIN_SUFFIX}
    VOLUMES=${VOLUMESBASE}/${CONTAINER_NAME}
    $CONTAINER_ENGINE stop "${CONTAINER_NAME}" || true
    $CONTAINER_ENGINE rm "${CONTAINER_NAME}" || true
    if test -z "$VOLUMESBASE"
    then
	DOCKER_CREATE_ARGS="\
	-v ${CONTAINER_NAME}-rpmbuild:/root/rpmbuild \
	-v ${CONTAINER_NAME}-m2:/root/.m2 \
	-v ${CONTAINER_NAME}-go:/root/go \
	-v ${CONTAINER_NAME}-ccache:/root/.ccache \
	"
    else
	DOCKER_CREATE_ARGS="\
	-v ${VOLUMES}/rpmbuild:/root/rpmbuild \
	-v ${VOLUMES}/m2:/root/.m2 \
	-v ${VOLUMES}/go:/root/go \
	-v ${VOLUMES}/ccache:/root/.ccache \
	"
    fi

    ./refresh-test-repo || exit 1
    if $SPLIT_MODE
    then
	run_container srpm || exit 1
	run_container rebuild
    elif $REBUILD_MODE
    then
	run_container cleanrebuild
    else
	run_container
    fi
}
