#!/usr/bin/env sh
  
set -xeu

# Needed to build vespa
dnf -y install epel-release
dnf -y install dnf-plugins-core dnf-plugin-ovl
dnf -y copr enable @vespa/vespa centos-stream-8
dnf config-manager --enable powertools
dnf -y install \
        ccache \
        git \
        iputils \
        jq \
        pinentry \
        sudo


GIT_REPO="https://github.com/vespa-engine/vespa.git"

# Change git reference for a specific version of the vespa.spec file. Use a tag or SHA to allow for reproducible builds.
VESPA_SRC_REF="9d6df99dddf675207971db94c852fd3e8796e077"

# Install vespa build and runtime dependencies
git clone $GIT_REPO && cd vespa && git -c advice.detachedHead=false checkout $VESPA_SRC_REF
sed -e '/^BuildRequires:/d' -e '/^Requires: %{name}/d' -e 's/^Requires:/BuildRequires:/' dist/vespa.spec > dist/vesparun.spec
dnf -y module enable maven:3.8
dnf builddep --nobest -y dist/vespa.spec dist/vesparun.spec
cd .. && rm -r vespa
alternatives --set java java-17-openjdk.$(arch)
alternatives --set javac java-17-openjdk.$(arch)
dnf install -y maven-openjdk17

printf '%s\n%s\n' "# gcc" "source /opt/rh/gcc-toolset-12/enable"  > /etc/profile.d/enable-gcc-toolset-12.sh
printf '%s\n%s\n' "* soft nproc 409600"  "* hard nproc 409600"    > /etc/security/limits.d/99-nproc.conf
printf '%s\n%s\n' "* soft core 0"        "* hard core unlimited"  > /etc/security/limits.d/99-coredumps.conf
printf '%s\n%s\n' "* soft nofile 262144" "* hard nofile 262144"   > /etc/security/limits.d/99-nofile.conf

# Install Ruby in build image that is required for running system test in PR jobs for both Vespa and system tests
dnf -y module enable ruby:3.0
dnf -y install \
    clang \
    gcc-toolset-12-annobin-plugin-gcc \
    gcc-toolset-12-libasan-devel \
    gcc-toolset-12-libtsan-devel \
    gcc-toolset-12-libubsan-devel \
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
    rubygem-test-unit
( . /opt/rh/gcc-toolset-12/enable && \
  /usr/lib/rpm/redhat/redhat-annobin-plugin-select.sh )

dnf -y install vespa-toolset-12-meta

(source /opt/rh/gcc-toolset-12/enable && gem install ffi libxml-ruby)
python3.9 -m pip install pytest

# Python 3.11 is pulled in as a transitive dependency of valgrind. This causes it to be set as default. We use 3.9 for now.
alternatives --set python3 /usr/bin/python3.9

dnf clean all --enablerepo='*'
