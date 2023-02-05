#!/usr/bin/env sh
  
set -xeu

# Change git reference for a specific version of the vespa.spec file.
# Use a tag or SHA to allow for reproducible builds.
VESPA_SRC_REF="66ab5019e94625935f4766e0caeed497dc31e2dd"
GIT_REPO="https://github.com/vespa-engine/vespa"

# Enable and install repositories
dnf -y install epel-release
dnf -y install dnf-plugins-core dnf-plugin-ovl
dnf -y copr enable @vespa/vespa centos-stream-8
dnf config-manager --enable powertools

# Java requires proper locale for unicode
export LANG=C.UTF-8

# Use newer maven and java
dnf -y module enable maven:3.8

# Some generally useful packages
dnf -y install \
    ccache \
    iputils \
    jq \
    pinentry \
    sudo \
    git \
    curl \
    wget

# Fetch the RPM spec for vespa
wget $GIT_REPO/raw/$VESPA_SRC_REF/dist/vespa.spec

# Pick runtime dependencies
sed -e '/^BuildRequires:/d' \
    -e '/^Requires: %{name}/d' \
    -e 's/^Requires:/BuildRequires:/' < vespa.spec > vesparun.spec

# Install vespa build and runtime dependencies
dnf builddep --nobest -y vespa.spec vesparun.spec

rm vespa.spec vesparun.spec

#  Install extra compiler tools
dnf -y install \
    gcc-toolset-12-annobin-plugin-gcc \
    gcc-toolset-12-libasan-devel \
    gcc-toolset-12-libtsan-devel \
    gcc-toolset-12-libubsan-devel

source /opt/rh/gcc-toolset-12/enable
/usr/lib/rpm/redhat/redhat-annobin-plugin-select.sh

# Install Ruby in build image that is required for running system test in PR jobs for both Vespa and system tests
dnf -y module enable ruby:3.0
dnf -y install \
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

# compile two rubygems
gem install ffi libxml-ruby

printf '%s\n'  "# gcc"  "source /opt/rh/gcc-toolset-12/enable"  > /etc/profile.d/enable-gcc-toolset-12.sh
printf '%s\n'  "* soft nproc 409600"   "* hard nproc 409600"    > /etc/security/limits.d/99-nproc.conf
printf '%s\n'  "* soft core 0"         "* hard core unlimited"  > /etc/security/limits.d/99-coredumps.conf
printf '%s\n'  "* soft nofile 262144"  "* hard nofile 262144"   > /etc/security/limits.d/99-nofile.conf

# cleanup
dnf clean all --enablerepo='*'
rm -rf /var/cache/yum
