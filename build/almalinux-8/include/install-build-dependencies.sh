#!/usr/bin/env sh
  
set -xeu

# Java requires proper locale for unicode
export LANG=C.UTF-8

# Setup repos needed build vespa
dnf -y install epel-release
dnf -y install dnf-plugins-core dnf-plugin-ovl
dnf -y copr enable @vespa/vespa epel-8
dnf config-manager --enable powertools

# Use newer maven and ruby
dnf -y module enable maven:3.8
dnf -y module enable ruby:3.1

dnf -y install \
    ccache \
    curl \
    git-core \
    iputils \
    jq \
    pinentry \
    rpmdevtools \
    sudo

GIT_REPO="https://github.com/vespa-engine/vespa.git"

# Change git reference for a specific version of the vespa.spec file. Use a tag or SHA to allow for reproducible builds.
VESPA_SRC_REF="c2acf662cb1f58b076e2b901bee116a4fbd1603c"

# Fetch the RPM spec for vespa
curl -Lf -O $GIT_REPO/raw/$VESPA_SRC_REF/dist/vespa.spec

# Pick runtime dependencies
sed -e '/^BuildRequires:/d' \
    -e '/^Requires: %{name}/d' \
    -e 's/^Requires:/BuildRequires:/' < vespa.spec > vesparun.spec

rm -f vespa.spec vesparun.spec

printf '%s\n%s\n' "# gcc" "source /opt/rh/gcc-toolset-12/enable"  > /etc/profile.d/enable-gcc-toolset-12.sh
printf '%s\n%s\n' "* soft nproc 409600"  "* hard nproc 409600"    > /etc/security/limits.d/99-nproc.conf
printf '%s\n%s\n' "* soft core 0"        "* hard core unlimited"  > /etc/security/limits.d/99-coredumps.conf
printf '%s\n%s\n' "* soft nofile 262144" "* hard nofile 262144"   > /etc/security/limits.d/99-nofile.conf

# Install Ruby in build image that is required for running system test in PR jobs for both Vespa and system tests
dnf -y install \
    clang \
    gcc-toolset-12-libatomic-devel \
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

# Compile two rubygems
gem install ffi libxml-ruby

# Install docker client  to avoid doing this in all pipelines.
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io

# Cleanup
dnf clean all --enablerepo='*'
rm -rf /var/cache/yum
