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

f=/usr/local/bin/cfmt
cat > $f << 'EOF'
#!/bin/sh
echo "Formatting C++ code in" $(pwd)
suff=".$$.reformatted"
dofmt() {
	if [ -f $1 ]; then
		out=$1.$suff
		if clang-format --fail-on-incomplete-format $1 > $out; then
			if cmp -s $1 $out; then
				rm "$out"
			else
				echo "Updated $1"
				diff -w -U 1 "$1" "$out"
				mv "$out" "$1"
			fi
		else
			echo "FAILED formatting $1"
			rm "$out"
		fi
	fi
}
for fn in $(find . -name '*.h' -o -name '*.hpp' -o -name '*.cpp')
do
	dofmt $fn &
done
wait
EOF
chmod +x $f

echo "Clean up..."
dnf clean all --enablerepo=\*
