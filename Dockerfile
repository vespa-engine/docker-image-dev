# Copyright 2017 Yahoo Holdings. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
FROM centos:7

# Needed to build vespa
RUN yum-config-manager --add-repo https://copr.fedorainfracloud.org/coprs/g/vespa/vespa/repo/epel-7/group_vespa-vespa-epel-7.repo && \
    yum -y install epel-release && \
    yum -y install centos-release-scl && \
    yum -y --enablerepo=epel-testing install \
        ccache \
        cmake3 \
        devtoolset-6-binutils \
        devtoolset-6-gcc-c++ \
        devtoolset-6-libatomic-devel \
        git \
        java-1.8.0-openjdk-devel \
        Judy-devel \
        libicu-devel \
        libzstd-devel \
        llvm3.9-devel \
        llvm3.9-static \
        lz4-devel \
        make \
        maven \
        openssl \
        openssl-devel \
        perl \
        perl-Data-Dumper \
        perl-Env \
        perl-IO-Socket-IP \
        perl-JSON \
        perl-libwww-perl \
        perl-Net-INET6Glue \
        perl-URI \
        rpm-build \
        sudo \
        valgrind \
        'vespa-boost-devel >= 1.59.0-7' \
        'vespa-cppunit-devel >= 1.12.1-7' \
        'vespa-libtorrent-devel >= 1.0.11-7' \
        'vespa-zookeeper-c-client-devel >= 3.4.9-7' \
        zlib-devel && \
    yum clean all && \
    echo "source /opt/rh/devtoolset-6/enable" > /etc/profile.d/devtoolset-6.sh && \
    echo "*          soft    nproc     32768" > /etc/security/limits.d/90-nproc.conf

# Java requires proper locale for unicode
ENV LANG en_US.UTF-8
