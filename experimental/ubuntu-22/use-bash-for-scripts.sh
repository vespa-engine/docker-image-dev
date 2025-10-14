#!/usr/bin/env bash
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

oldhashbang='#!/bin/sh'
newhashbang='#!/bin/bash'

if [ -f $VESPA_HOME/libexec/vespa/common-env.sh ]; then
	echo "Changing shell scripts in $VESPA_HOME"
else
	echo "Please set VESPA_HOME first"
	exit 1
fi

find $VESPA_HOME -type f -size -20 -print | while read filename; do
	firstline=$(head -n 1 < ${filename})
	if [ "$firstline" = "$oldhashbang" ]; then
		echo "Fixing ${filename}"
		( echo "$newhashbang"; cat ${filename} ) > ${filename}.bash
		chmod +x ${filename}.bash
		mv ${filename}.bash ${filename}
	fi
done
