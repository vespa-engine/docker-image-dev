#!/usr/bin/env bash
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

# Install sshd, man-db, nice-to-have packages and system test dependencies
dnf -y install \
  bind-utils \
  xorg-x11-xauth \
  rsync \
  nmap-ncat \
  vim \
  emacs-nox \
  wget \
  gdb \
  hunspell-en \
  kdesdk-kcachegrind \
  graphviz

dnf -y install openssh-server

# Manage System Python
"$(dirname "$0")/setup-python.sh" 3.12

echo "Clean up..."
dnf clean all --enablerepo=\*
