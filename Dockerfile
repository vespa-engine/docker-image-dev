# Copyright 2018 Yahoo Holdings. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
FROM centos:7

# Needed to build vespa
RUN yum-config-manager --add-repo https://copr.fedorainfracloud.org/coprs/g/vespa/vespa/repo/epel-7/group_vespa-vespa-epel-7.repo && \
    yum -y install epel-release && \
    yum -y install centos-release-scl && \
    yum -y --enablerepo=epel-testing install \
        git \
        yum-utils \
        ccache \
        sudo

ENV GIT_REPO "https://github.com/vespa-engine/vespa.git"

# Change git reference for a specific version of the vespa.spec file. Use a tag or SHA to allow for reproducible builds.
ENV VESPA_SRC_REF "344b478be6b3a5ff9419c2e857e763fdede5f010"

# Install vespa build and runtime dependencies
RUN git clone $GIT_REPO && cd vespa && git -c advice.detachedHead=false checkout $VESPA_SRC_REF && \
    sed -e '/^BuildRequires:/d' -e 's/^Requires:/BuildRequires:/' dist/vespa.spec > dist/vesparun.spec && \
    yum-builddep -y dist/vespa.spec dist/vesparun.spec && \
    cd .. && rm -r vespa && \
    curl -s "https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz" --output openjdk11.tar.gz && \
    tar xf openjdk11.tar.gz -C /usr/local && \
    rm openjdk11.tar.gz && \
    mv /usr/local/jdk-11.0.1 /usr/local/jdk-11 && \
    alternatives --install /usr/bin/java java /usr/local/jdk-11/bin/java 2 && \
    alternatives --set java /usr/local/jdk-11/bin/java && \
    alternatives --install /usr/bin/jar jar /usr/local/jdk-11/bin/jar 2 && \
    alternatives --set jar /usr/local/jdk-11/bin/jar && \
    alternatives --install /usr/bin/javac javac /usr/local/jdk-11/bin/javac 2 && \
    alternatives --set javac /usr/local/jdk-11/bin/javac && \
    yum clean all && rm -rf /var/cache/yum && \
    echo -e "#!/bin/bash\nsource /opt/rh/devtoolset-7/enable" >> /etc/profile.d/enable-devtoolset-7.sh && \
    echo -e "#!/bin/bash\nsource /opt/rh/rh-maven35/enable" >> /etc/profile.d/enable-rh-maven35.sh && \
    echo -e "* soft nproc 409600\n* hard nproc 409600" > /etc/security/limits.d/99-nproc.conf && \
    echo -e "* soft nofile 262144\n* hard nofile 262144" > /etc/security/limits.d/99-nofile.conf

# Java requires proper locale for unicode
ENV LANG en_US.UTF-8
