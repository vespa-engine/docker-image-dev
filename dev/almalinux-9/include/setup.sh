#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Install sshd, man-db, nice-to-have packages and system test dependencies
dnf -y install \
  bind-utils \
  xorg-x11-xauth \
  rsync \
  nmap-ncat \
  vim \
  wget \
  gdb \
  hunspell-en \
  kdesdk-kcachegrind \
  graphviz

# Manage System Python
"$(dirname "$0")/setup-python.sh" 3.12

echo "Clean up..."
dnf clean all --enablerepo=\*
