#!/bin/bash

set -x
set -e

source $HOME/.docker_profile

export VESPA_HOME=$HOME/vespa
export LD_LIBRARY_PATH=/opt/vespa-deps/lib64

mkdir -p $HOME/build-vespa
cd $HOME/build-vespa

if [ -d vespa ]; then
	echo '~/build-vespa/vespa already present; skipping git clone'
else
	git clone https://github.com/vespa-engine/vespa.git
fi
cd vespa

./bootstrap.sh java

cmake .

./mvnw -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -T 1C install

make -j8 install

# optional: run tests
./mvnw -T 1C install

ctest -j8
