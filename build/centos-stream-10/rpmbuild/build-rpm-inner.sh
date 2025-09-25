#!/bin/sh -ex
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# shellcheck source=../../../shared-rpmbuild/build-rpm-inner-common.sh
. /shared-work/build-rpm-inner-common.sh

enable_repos()
{
    dnf -y install epel-release
    dnf -y install 'dnf-command(config-manager)'
    /usr/bin/crb enable
}

build_rpm_inner_common "$@"
