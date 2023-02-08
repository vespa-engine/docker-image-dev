# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM docker.io/vespaengine/vespa-build-almalinux-8:latest

# Install sshd, man-db, nice-to-have packages and system test dependencies
RUN dnf -y install \
        bind-utils \
        openssh-server \
        xorg-x11-xauth \
        rsync \
        nmap-ncat \
        vim \
        emacs \
        man-db \
        man-pages \
        hunspell-en && \
    dnf -y install \
        gcc-toolset-12-libasan-devel \
        gcc-toolset-12-libtsan-devel \
        gcc-toolset-12-libubsan-devel && \
    dnf -y install \
        kdesdk-kcachegrind \
        graphviz && \
    dnf clean all --enablerepo=\* 

RUN useradd -M -d /opt/vespa -s /usr/sbin/nologin vespa

STOPSIGNAL SIGRTMIN+3

CMD [ "/usr/sbin/init" ]
