#!/usr/bin/env bash
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <python-version>"
  exit 1
fi

PYTHON_VERSION="${1}"
if [[ ! "$PYTHON_VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid Python version format. Please use 'X.Y' format."
  exit 1
fi

echo "Install Python and pip"
dnf -y install "python${PYTHON_VERSION}" "python${PYTHON_VERSION}-pip"


echo "Install alternatives for python3 and pip3"
alternatives --install /usr/bin/python3 python3 "/usr/bin/python${PYTHON_VERSION}" 1 \
  --slave /usr/bin/pip3 pip3 "/usr/bin/pip${PYTHON_VERSION}"

echo "Set python3 to version '${PYTHON_VERSION}'"
alternatives --set python3 "/usr/bin/python${PYTHON_VERSION}"

echo "Upgrade pip.."
pip3 install --upgrade pip

echo "Python ${PYTHON_VERSION} and pip3 have been installed successfully."
