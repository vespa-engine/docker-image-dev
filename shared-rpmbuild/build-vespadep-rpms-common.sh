#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

is_el8()
{
    case "${CONTAINER_SHORTNAME}" in
	a8|ol8|r8) return 0;;
	*) return 1;;
    esac
}

is_el9()
{
    case "${CONTAINER_SHORTNAME}" in
	a9|cs9) return 0;;
	*) return 1;;
    esac
}

is_el10()
{
    case "${CONTAINER_SHORTNAME}" in
	a10|cs10) return 0;;
	*) return 1;;
    esac
}

is_amzn2023()
{
    case "${CONTAINER_SHORTNAME}" in
	amzn2023) return 0;;
	*) return 1;;
    esac
}

is_fedora()
{
    case "${CONTAINER_SHORTNAME}" in
	fc43|fc44|rawhide) return 0;;
	*) return 1;;
    esac
}

should_build_rpm()
{
    # pkg argument
    case "$1" in
	toolset-14) is_el8 || is_el9;;
	toolset-15) is_el8 || is_el9 || is_el10;;
	lz4) return 0;;
	zstd) return 0;;
	openssl) is_el8;;
	cmake) is_el8 || is_el9 || is_amzn2023;;
	ccache) is_el8 || is_el9 || is_amzn2023;;
	gtest) is_el8 || is_el9 || is_amzn2023;;
	gradle) return 0;;
	cuda-fix) is_el8 || is_el9 || is_el10;;
	onnxruntime) return 0;;
	gcc14-annobin-plugin) is_amzn2023;;
	abseil-cpp) is_el8 || is_el9 || is_amzn2023;;
	openblas) return 0;;
	gbenchmark) return 0;;
	highway) return 0;;
	mimalloc) return 0;;
	protobuf) return 0;;
	jllama) return 0;;
	datasketches) return 0;;
	icu) is_el8 || is_el9 || is_el10;;
	re2) is_el8 || is_el9 || is_el10;;
	valgrind) is_el8;;
	xxhash) is_amzn2023;;
	build-dependencies) return 0;;
	pybind11) is_el8;;
	*) echo "Bad package '$1'" 1>&2; exit 1;;
    esac
}

build_rpm()
{
    # pkg argument
    echo "Executing ./build-rpm.sh -a -s $1"
    ./build-rpm.sh -a -s "$1" || exit 1
}

consider_build_rpm()
{
    # pkg argument
    if should_build_rpm "$1"; then
	build_rpm "$1"
    fi
}

build_vespadep_rpms_common()
{
    packages="$*"
    if test -n "$packages"; then
	for pkg in $packages
	do
	    consider_build_rpm $pkg
	done
	return 0
    fi
    consider_build_rpm toolset-14
    consider_build_rpm toolset-15
    consider_build_rpm lz4
    consider_build_rpm zstd
    consider_build_rpm openssl
    consider_build_rpm cmake
    consider_build_rpm ccache
    consider_build_rpm gtest
    consider_build_rpm gradle
    consider_build_rpm cuda-fix
    consider_build_rpm onnxruntime
    consider_build_rpm gcc14-annobin-plugin
    consider_build_rpm abseil-cpp
    consider_build_rpm openblas
    consider_build_rpm gbenchmark
    consider_build_rpm highway
    consider_build_rpm mimalloc
    consider_build_rpm protobuf
    consider_build_rpm jllama
    consider_build_rpm datasketches
    consider_build_rpm icu
    consider_build_rpm re2
    consider_build_rpm valgrind
    consider_build_rpm xxhash
    consider_build_rpm build-dependencies
    # for compiling vespa-ann-benchmark in dev environment
    consider_build_rpm pybind11
    echo DONE
}
