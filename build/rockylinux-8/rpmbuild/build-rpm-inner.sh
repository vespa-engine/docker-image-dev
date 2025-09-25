#!/bin/sh -ex
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# shellcheck source=../../../shared-rpmbuild/build-rpm-inner-common.sh
. /shared-work/build-rpm-inner-common.sh

enable_repos()
{
    dnf -y install epel-release
    dnf -y install dnf-plugin-ovl
    dnf -y install 'dnf-command(config-manager)'
    /usr/bin/crb enable
}

enable_modules()
{
    dnf -y module enable maven:3.8
    dnf -y module enable ruby:3.1
}

enable_cuda_repos()
{
    enable_cuda_repos_helper rhel8
}

build_rpm_inner_common "$@"
