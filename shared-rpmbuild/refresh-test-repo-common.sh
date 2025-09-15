#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

refresh_test_repo_common()
{
    # shellcheck source=../shared/common.sh
    . ../../../shared/common.sh

    if test -f /usr/bin/createrepo_c
    then
	mkdir -p "RPMS/$(arch)"
	createrepo_c "RPMS/$(arch)"
    else
	# shellcheck disable=SC2016
	$CONTAINER_ENGINE run --rm -v "$(env pwd):/work" "${DOCKER_IMAGE}" bash -c 'dnf -y install createrepo_c && mkdir -p /work/RPMS/$(arch) && createrepo_c /work/RPMS/$(arch) && chown -R --ref /work/build-rpm-inner.sh /work/RPMS'
    fi
}
