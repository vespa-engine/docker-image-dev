# Copyright 2018 Yahoo Holdings. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
FROM centos:7

# Needed to build vespa
RUN yum-config-manager --add-repo https://copr.fedorainfracloud.org/coprs/g/vespa/vespa/repo/epel-7/group_vespa-vespa-epel-7.repo && \
    yum -y install epel-release && \
    yum -y install centos-release-scl && \
    yum -y --enablerepo=epel-testing install git yum-utils

ENV GIT_REPO "https://github.com/vespa-engine/vespa.git"

# Change git reference for a specific version of the vespa.spec file. Use a tag or SHA to allow for reproducible builds.
ENV VESPA_SRC_REF "ac8b53179c27f71916fd4dc48852dad2f2e79764"

RUN git clone $GIT_REPO && cd vespa && git -c advice.detachedHead=false checkout $VESPA_SRC_REF && \
    yum-builddep -y dist/vespa.spec && cd .. && rm -r vespa && \
    yum clean all && rm -rf /var/cache/yum && \
    echo "source /opt/rh/devtoolset-7/enable" >> /etc/profile.d/devtoolset-7.sh && \
    echo "source /opt/rh/rh-maven35/enable" >> /etc/profile.d/devtoolset-7.sh && \
    echo "*          soft    nproc     32768" > /etc/security/limits.d/90-nproc.conf

# Java requires proper locale for unicode
ENV LANG en_US.UTF-8
