# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
FROM docker.io/vespaengine/vespa-build-centos-stream8:latest

ENV container docker

# Install sshd, man-db, nice-to-have packages and system test dependencies
RUN dnf -y clean all && \
    dnf -y install 'dnf-command(versionlock)' && \
    dnf versionlock llvm-libs && \
    dnf -y --nobest update && \
    dnf -y module enable ruby:2.7 && \
    dnf -y install \
        bind-utils \
        openssh-server \
        xorg-x11-xauth \
        libxml2-devel \
        ruby \
        ruby-devel \
        rubygem-net-telnet \
        rubygems-devel \
        nmap-ncat \
        vim \
        emacs \
        man-db \
        man-pages \
        hunspell-en && \
    dnf -y install \
        gcc-toolset-11-annobin-plugin-gcc \
        gcc-toolset-11-gdb \
        gcc-toolset-11-libasan-devel \
        gcc-toolset-11-libtsan-devel \
        gcc-toolset-11-libubsan-devel && \
    dnf -y install \
        kdesdk-kcachegrind \
        graphviz && \
    (source /opt/rh/gcc-toolset-11/enable && \
     gem install libxml-ruby gnuplot distribution test-unit builder concurrent-ruby ffi) && \
    dnf clean all --enablerepo=\* 

STOPSIGNAL SIGRTMIN+3

CMD [ "/usr/sbin/init" ]
