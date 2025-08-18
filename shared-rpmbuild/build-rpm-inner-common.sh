#!/bin/sh -ex
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

enable_repos()
{
    :
}

enable_modules()
{
    :
}

enable_cuda_repos()
{
    :
}

legacy_dnf()
{
    dnf "$@"
}

enable_cuda_repos_helper()
{
    # https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html
    distro=$1
    cpu_arch=$(arch)
    case "$cpu_arch" in
	aarch64) arch=sbsa;;
	*) arch=$cpu_arch;;
    esac
    dnf config-manager --add-repo "https://developer.download.nvidia.com/compute/cuda/repos/$distro/$arch/cuda-$distro.repo"
}

build_rpm_inner_common()
{
    package=$1
    mode=${2:-both}
    case "$mode" in
	both|srpm|rebuild)
	;;
	cleanrebuild)
	    mode=rebuild
	    rm -rf ~/rpmbuild/*
	    ;;
	*) echo "Wrong build mode $mode" 1>&2
	   exit 1
	   ;;
    esac

    if test -f /tmp/.build-rpm-inner-installed-build-tools
    then
	:
    else
	touch /var/lib/rpm/*
	dnf -y clean all --enablerepo='*'
	enable_repos
	dnf -y upgrade
	case "$mode" in
	    both|srpm)
		dnf -y install dnf-utils rpm-build make git rsync
		;;
	    rebuild)
		dnf -y install dnf-utils rpm-build
		;;
	esac
	touch /tmp/.build-rpm-inner-installed-build-tools
    fi
    case "$mode" in
	both|rebuild)
	    /work/setup-test-repo
	    case $package in
		onnxruntime|jllama)
		    enable_cuda_repos
		    ;;
		vespa)
		    dnf -y install ccache
		    ;;
	    esac
	    ;;
    esac
    case "$mode" in
	both|srpm)
	    rm -rf ~/rpmbuild/*
	    mkdir -p ~/rpmbuild/SRPMS
	    ;;
	rebuild)
	    rm -rf ~/rpmbuild/BUILD ~/rpmbuild/BUILDROOT
	    ;;
    esac
    case "$package" in
	vespa|vespa-ann-benchmark)
	    case "$mode" in
		both|srpm)
		    git config --global --add safe.directory /src
		    vespaversion=$(cd /src && git tag -l | sed -n -r -e 's,^v([0-9]+\.[0-9]+\.[0-9]+)$,\1,p' | sort -V | tail -1)
		    ( cd /src && ./dist.sh "$vespaversion" )
		    ;;
		rebuild)
		    # shellcheck disable=SC2086
		    vespaversion=$(cd ~/rpmbuild/SPECS && echo $package-[0-9]*.spec | sed -n -e 's,^'$package'-\([0-9.]*\)\.spec$,\1,p')
		    if test -z "$vespaversion"
		    then
			echo "Failed to pick up vespa version" 1>&2
			exit 1
		    fi
		    ;;
	    esac
	    specname=$package-$vespaversion
	    ;;
	*)
	    case "$mode" in
		both|srpm)
		    SRC=/src-copy
		    rsync -aHvSx --delete /src/ $SRC/
		    make -C "$SRC/$package" -f .copr/Makefile srpm outdir=~/rpmbuild/SRPMS
		    rm -rf "$SRC/$package/.copr/rpmbuild"
		    ;;
	    esac
	    case "$mode" in
		both|rebuild)
		    rmdir ~/rpmbuild/SRPMS 2>/dev/null || true
		    if test -d ~/rpmbuild/SRPMS
		    then
			# shellcheck disable=SC2086
			rpm -i ~/rpmbuild/SRPMS/vespa-$package-*.src.rpm
		    else
			# shellcheck disable=SC2086
			rpm -i /work/vespa-$package-*.src.rpm
		    fi
		    case "$package" in
			datasketches) specname=vespa-$package-cpp;;
		        *) specname=vespa-$package;;
		    esac
		    ;;
	    esac
	    ;;
    esac
    case "$mode" in
	both|rebuild)
	    case "$package" in
		vespa|vespa-ann-benchmark|jllama|jllama-cuda)
		    enable_modules
		    ;;
	    esac
	    legacy_dnf -y install 'dnf-command(builddep)'
	    legacy_dnf -y builddep ~/rpmbuild/SPECS/"$specname".spec
	    if test -x /usr/bin/go
	    then
		go env -w GOPROXY="https://proxy.golang.org,direct"
		mkdir -p ~/tmp
		export GOTMPDIR=~/tmp
	    fi
	    # shellcheck disable=SC2015
	    rpm -q ccache >/dev/null 2>&1 && ccache -M 16G || true
	    # shellcheck disable=SC3045
	    ( ulimit -Sc 0; rpmbuild -ba ~/rpmbuild/SPECS/"$specname".spec )
	    ;;
    esac
    ARCH=$(arch)
    mkdir -p "/work/RPMS/${ARCH}" /work/SRPMS
    case "$mode" in
	both|rebuild)
	    cp -p ~/rpmbuild/RPMS/*/*.rpm "/work/RPMS/${ARCH}"
	    cp -p ~/rpmbuild/SRPMS/*.src.rpm /work/SRPMS
	    chown --reference=/work/build-rpm-inner.sh -R /work/RPMS /work/SRPMS
	    rm -rf ~/rpmbuild/*
	    ;;
    esac
}
