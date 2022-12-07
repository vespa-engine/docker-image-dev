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
        iputils \
        jq \
        pinentry \
        sudo

ENV GIT_REPO "https://github.com/vespa-engine/vespa.git"

# Change git reference for a specific version of the vespa.spec file. Use a tag or SHA to allow for reproducible builds.
ENV VESPA_SRC_REF "8f32428bb05196e8b6c9c3855864a9ec51dd250d"

# Install vespa build and runtime dependencies
RUN git clone $GIT_REPO && cd vespa && git -c advice.detachedHead=false checkout $VESPA_SRC_REF && \
    sed -e '/^BuildRequires:/d' -e '/^Requires: %{name}/d' -e 's/^Requires:/BuildRequires:/' dist/vespa.spec > dist/vesparun.spec && \
    dnf -y module enable maven:3.6 && \
    dnf builddep --nobest -y dist/vespa.spec dist/vesparun.spec && \
    cd .. && rm -r vespa && \
    alternatives --set java java-17-openjdk.$(arch) && \
    alternatives --set javac java-17-openjdk.$(arch) && \
    dnf clean all && rm -rf /var/cache/yum && \
    echo -e "#!/bin/bash\nsource /opt/rh/gcc-toolset-11/enable" >> /etc/profile.d/enable-gcc-toolset-11.sh && \
    echo -e "* soft nproc 409600\n* hard nproc 409600" > /etc/security/limits.d/99-nproc.conf && \
    echo -e "* soft nofile 262144\n* hard nofile 262144" > /etc/security/limits.d/99-nofile.conf

# Install Ruby in build image that is required for running system test in PR jobs for both Vespa and system tests
RUN dnf -y module enable ruby:3.0 && \
    dnf -y install \
        gcc-toolset-11-annobin-plugin-gcc \
        gcc-toolset-11-libasan-devel \
        gcc-toolset-11-libtsan-devel \
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
    ( . /opt/rh/gcc-toolset-11/enable && \
      /usr/lib/rpm/redhat/redhat-annobin-plugin-select.sh ) && \
    (source /opt/rh/gcc-toolset-11/enable && \
     gem install ffi libxml-ruby) && \
    dnf clean all --enablerepo=\*

# Java requires proper locale for unicode
ENV LANG en_US.UTF-8
