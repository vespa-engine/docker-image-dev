# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
FROM quay.io/centos/centos:stream8

# Needed to build vespa
RUN dnf -y install epel-release && \
    dnf -y install \
      dnf-plugins-core \
      dnf-plugin-ovl && \
    dnf -y copr enable @vespa/vespa centos-stream-8 && \
    dnf config-manager --enable powertools && \
    dnf -y install \
        ccache \
        git \
        hostname \
        iputils \
        java-17-openjdk-devel \
        jq \
        pinentry \
        sudo

ENV GIT_REPO "https://github.com/vespa-engine/vespa.git"

# Change git reference for a specific version of the vespa.spec file. Use a tag or SHA to allow for reproducible builds.
ENV VESPA_SRC_REF "704f95e5b7592577f2d45e905666e073646bcfaf"

# Install vespa build and runtime dependencies
RUN git clone $GIT_REPO && cd vespa && git -c advice.detachedHead=false checkout $VESPA_SRC_REF && \
    sed -e '/^BuildRequires:/d' -e '/^Requires: %{name}-/d' -e 's/^Requires:/BuildRequires:/' dist/vespa.spec > dist/vesparun.spec && \
    dnf -y module enable maven:3.6 && \
    dnf builddep --nobest -y dist/vespa.spec dist/vesparun.spec && \
    cd .. && rm -r vespa && \
    alternatives --set java $(alternatives --display java | grep "java.*priority" | awk '{print $1}' | grep "jdk-17") && \
    dnf swap -y maven-openjdk11 maven-openjdk17 && \
    dnf clean all && rm -rf /var/cache/yum && \
    echo -e "#!/bin/bash\nsource /opt/rh/gcc-toolset-11/enable" >> /etc/profile.d/enable-gcc-toolset-11.sh && \
    echo -e "* soft nproc 409600\n* hard nproc 409600" > /etc/security/limits.d/99-nproc.conf && \
    echo -e "* soft nofile 262144\n* hard nofile 262144" > /etc/security/limits.d/99-nofile.conf

# Java requires proper locale for unicode
ENV LANG en_US.UTF-8
