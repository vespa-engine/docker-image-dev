# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM almalinux:8.7

# Enable and install repositories
RUN dnf -y install epel-release && \
    dnf -y install dnf-plugins-core dnf-plugin-ovl && \
    dnf -y copr enable @vespa/vespa centos-stream-8 && \
    dnf config-manager --enable powertools

# Java requires proper locale for unicode
ENV LANG C.UTF-8

# Use newer maven and java
RUN dnf -y module enable maven:3.8

ENV GIT_REPO "https://github.com/vespa-engine/vespa.git"
RUN dnf -y install git

# Change git reference for a specific version of the vespa.spec file.
# Use a tag or SHA to allow for reproducible builds.
ENV VESPA_SRC_REF "66ab5019e94625935f4766e0caeed497dc31e2dd"

# Install vespa build and runtime dependencies
RUN git clone $GIT_REPO && cd vespa && git -c advice.detachedHead=false checkout $VESPA_SRC_REF && \
    sed -e '/^BuildRequires:/d' -e '/^Requires: %{name}/d' -e 's/^Requires:/BuildRequires:/' dist/vespa.spec > dist/vesparun.spec && \
    dnf builddep --nobest -y dist/vespa.spec dist/vesparun.spec && \
    cd .. && rm -r vespa && \
    dnf clean all && rm -rf /var/cache/yum

RUN printf "%s\n" "#!/bin/bash" "source /opt/rh/gcc-toolset-12/enable" >> /etc/profile.d/enable-gcc-toolset-12.sh
RUN printf "%s\n" "* soft nproc 409600"  "* hard nproc 409600"  > /etc/security/limits.d/99-nproc.conf
RUN printf "%s\n" "* soft nofile 262144" "* hard nofile 262144" > /etc/security/limits.d/99-nofile.conf

# Install Ruby in build image that is required for running system test in PR jobs for both Vespa and system tests
RUN dnf -y module enable ruby:3.0 && \
    dnf -y install \
        gcc-toolset-12-annobin-plugin-gcc \
        libffi-devel \
        libxml2-devel \
        ruby \
        ruby-devel \
        rubygems \
        rubygems-devel \
        rubygem-bigdecimal \
        rubygem-builder \
        rubygem-builder-doc \
        rubygem-concurrent-ruby \
        rubygem-concurrent-ruby-doc \
        rubygem-parallel \
        rubygem-parallel-doc \
        rubygem-rexml \
        rubygem-test-unit && \
    (source /opt/rh/gcc-toolset-12/enable && \
     /usr/lib/rpm/redhat/redhat-annobin-plugin-select.sh && \
     gem install ffi libxml-ruby) && \
    dnf clean all --enablerepo='*'

# Some generally useful packages
RUN dnf -y install \
        ccache \
        iputils \
        jq \
        pinentry \
        sudo \
    && dnf clean all --enablerepo='*'
