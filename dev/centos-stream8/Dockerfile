# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
FROM docker.io/vespaengine/vespa-build-centos-stream8:latest

ENV container docker

# Install sshd, man-db, nice-to-have packages and system test dependencies
RUN dnf -y clean all && \
    dnf -y module enable ruby:2.7 && \
    dnf -y install \
        bind-utils \
        openssh-server \
        xorg-x11-xauth \
        libxml2-devel \
        rsync \
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
    dnf clean all --enablerepo=\* 

RUN source /opt/rh/gcc-toolset-11/enable && \
    (gem install ffi || true) && \
    cat /usr/local/lib64/gems/ruby/ffi-1.15.5/gem_make.out && \
    find /usr/local/lib64/gems/ruby/ffi-1.15.5
    
STOPSIGNAL SIGRTMIN+3

CMD [ "/usr/sbin/init" ]
