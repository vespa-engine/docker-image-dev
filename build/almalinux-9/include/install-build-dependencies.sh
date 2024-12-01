#!/usr/bin/env sh
  
set -xeu

VESPADEV_RPM_SOURCE="${1:-external}"

case "$VESPADEV_RPM_SOURCE" in
    external|test) ;;
    *) echo "Bad \$VESPADEV_RPM_SOURCE: $VESPADEV_RPM_SOURCE" 1>&2
       exit 1;;
esac

# Enable and install repositories
dnf -y install epel-release
dnf -y install dnf-plugins-core 
case "$VESPADEV_RPM_SOURCE" in
    external) dnf -y copr enable @vespa/vespa "epel-9-$(arch)";;
    test) /work/setup-test-repo;;
esac
dnf config-manager --enable crb

# Java requires proper locale for unicode
export LANG=C.UTF-8

# Use newest packages
dnf -y upgrade

# Use newer maven
dnf -y module enable maven:3.8

dnf -y install \
    awscli \
    ccache \
    createrepo \
    git-core \
    iputils \
    jq \
    pinentry \
    rpmdevtools \
    ShellCheck \
    sudo \
    time \
    valgrind

GIT_REPO="https://github.com/vespa-engine/vespa"

# Change git reference for a specific version of the vespa.spec file. Use a tag or SHA to allow for reproducible builds.
VESPA_SRC_REF="b0402dc7d475bc65ac85d5d989b915f28d343ab8"

# Fetch the RPM spec for vespa
curl -Lf -O $GIT_REPO/raw/$VESPA_SRC_REF/dist/vespa.spec

# Pick runtime dependencies
sed -e '/^BuildRequires:/d' \
    -e '/^Requires: %{name}/d' \
    -e 's/^Requires:/BuildRequires:/' < vespa.spec > vesparun.spec

# Install vespa build and runtime dependencies
dnf builddep --nobest -y vespa.spec vesparun.spec
rm -f vespa.spec vesparun.spec
gcc_version=$(rpm -qa | sed -ne "s/vespa-toolset-\([0-9][0-9]\)-meta.*/\1/p")

#  Install extra compiler tools
dnf -y install \
    clang \
    "gcc-toolset-$gcc_version-libasan-devel" \
    "gcc-toolset-$gcc_version-libtsan-devel" \
    "gcc-toolset-$gcc_version-libubsan-devel"

# shellcheck disable=SC1091
. /opt/rh/gcc-toolset/enable
/usr/lib/rpm/redhat/redhat-annobin-plugin-select.sh

# Install Ruby in build image that is required for running system test in PR jobs for both Vespa and system tests
dnf -y module enable ruby:3.3
dnf -y install \
    libffi-devel \
    ruby \
    ruby-devel \
    rubygems \
    rubygems-devel \
    rubygem-bigdecimal \
    rubygem-builder \
    rubygem-builder-doc \
    rubygem-concurrent-ruby \
    rubygem-concurrent-ruby-doc \
    rubygem-rexml \
    rubygem-test-unit

# Compile two rubygems
gem install ffi parallel

printf '%s\n'  "* soft nproc 409600"   "* hard nproc 409600"    > /etc/security/limits.d/99-nproc.conf
printf '%s\n'  "* soft core 0"         "* hard core unlimited"  > /etc/security/limits.d/99-coredumps.conf
printf '%s\n'  "* soft nofile 262144"  "* hard nofile 262144"   > /etc/security/limits.d/99-nofile.conf

if [ "$(arch)" = x86_64 ]; then
  GOARCH=amd64
else
  GOARCH=arm64
fi

GOTGZ="go1.22.4.linux-$GOARCH.tar.gz"
curl -sSL -O "https://go.dev/dl/$GOTGZ"
rm -rf /usr/local/go && tar -C /usr/local -xzf $GOTGZ
rm -f $GOTGZ
ln -sf /usr/local/go/bin/go /usr/local/bin/go
ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Install docker client  to avoid doing this in all pipelines.
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io

# Env wrapper for git access via ssh
cp -a /include/ssh-env-config.sh /usr/local/bin

dnf install -y https://github.com/sigstore/cosign/releases/latest/download/cosign-"$(curl -sSL https://api.github.com/repos/sigstore/cosign/releases/latest | jq -re '.tag_name|sub("^v";"")')"-1."$(arch)".rpm

TRIVY_VERSION=$(curl -sSL https://api.github.com/repos/aquasecurity/trivy/releases/latest |  jq -re '.tag_name|sub("^v";"")')
if [ "$(arch)" = x86_64 ]; then
  dnf install -y "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.rpm"
else
  dnf install -y "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-ARM64.rpm"
fi

# Cleanup
dnf clean all --enablerepo='*'
rm -rf /var/cache/yum
rm -f /etc/yum.repos.d/vespa-test.repo
