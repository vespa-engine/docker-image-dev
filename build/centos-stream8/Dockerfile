# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
FROM quay.io/centos/centos:stream8

COPY /include /tmp/include

RUN dnf install -y dnf-plugins-core && \
    dnf install -y epel-release && \
    dnf config-manager --enable powertools --enable epel && \
    dnf clean --enablerepo=* all

RUN dnf module enable -y ruby:3.0 && \
    dnf install -y \
        bind-utils \
        gcc-toolset-11-annobin \
        gcc-toolset-11-annobin-plugin-gcc \
        gcc-toolset-11-gcc-c++ \
        git \
        hostname \
        jq \
        libxml2-devel \
        lz4 \
        make \
        net-tools \
        python3-devel \
        redhat-rpm-config \
        ruby \
        ruby-devel \
        rubygems-devel \
        rubygem-bigdecimal \
        rubygem-builder \
        rubygem-concurrent-ruby \
        rubygem-parallel \
        rubygem-rexml \
        rubygem-test-unit \
        sudo \
        zstd \
        $(if [[ -e /tmp/include/additional-packages.txt ]]; then echo $(cat /tmp/include/additional-packages.txt | xargs); fi) && \
    dnf clean --enablerepo=* all


RUN source /opt/rh/gcc-toolset-11/enable && \
    gem install ffi libxml-ruby && \
    rm -rf /tmp/include

# Java requires proper locale for unicode
ENV LANG en_US.UTF-8
