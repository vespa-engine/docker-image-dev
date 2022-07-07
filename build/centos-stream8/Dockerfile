# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
FROM quay.io/centos/centos:stream8

COPY /include /tmp/include

RUN dnf install -y dnf-plugins-core && \
    dnf install -y epel-release && \
    dnf config-manager --enable powertools --enable epel && \
    dnf clean --enablerepo=* all

RUN dnf module enable -y ruby:3.0 && \
    dnf install -y \
        bind-utils \
        gcc-toolset-11-annobin \
        gcc-toolset-11-annobin-plugin-gcc \
        gcc-toolset-11-gcc-c++ \
        git \
        hostname \
        jq \
        libxml2-devel \
        lz4 \
        make \
        net-tools \
        python3-devel \
        redhat-rpm-config \
        ruby \
        ruby-devel \
        rubygems-devel \
        rubygem-bigdecimal \
        rubygem-builder \
        rubygem-concurrent-ruby \
        rubygem-parallel \
        rubygem-rexml \
        rubygem-test-unit \
        sudo \
        zstd \
        annobin binutils bzip2 c-ares cpp elfutils-debuginfod-client gc gcc gcc-gdb-plugin gdb gdb-headless glibc-langpack-en guile initscripts isl libasan libatomic libatomic_ops libbabeltrace libbpf libbsd libcgroup libcgroup-tools libev libgfortran libicu libretls libtool-ltdl libubsan llvm-libs mailcap netcat nghttp2 numactl numactl-libs opencsd perf perl perl-Algorithm-Diff perl-Archive-Tar perl-Archive-Zip perl-Attribute-Handlers perl-B-Debug perl-CPAN perl-CPAN-Meta perl-CPAN-Meta-Requirements perl-CPAN-Meta-YAML perl-Compress-Bzip2 perl-Compress-Raw-Bzip2 perl-Compress-Raw-Zlib perl-Config-Perl-V perl-DB_File perl-Data-Dump perl-Data-OptList perl-Data-Section perl-Devel-PPPort perl-Devel-Peek perl-Devel-SelfStubber perl-Devel-Size perl-Digest-HMAC perl-Digest-SHA perl-Encode-Locale perl-Encode-devel perl-Env perl-ExtUtils-CBuilder perl-ExtUtils-Command perl-ExtUtils-Embed perl-ExtUtils-Install perl-ExtUtils-MM-Utils perl-ExtUtils-MakeMaker perl-ExtUtils-Manifest perl-ExtUtils-Miniperl perl-ExtUtils-ParseXS perl-File-Fetch perl-File-HomeDir perl-File-Listing perl-File-Which perl-Filter perl-Filter-Simple perl-HTML-Parser perl-HTML-Tagset perl-HTTP-Cookies perl-HTTP-Date perl-HTTP-Message perl-HTTP-Negotiate perl-IO-Compress perl-IO-HTML perl-IO-Zlib perl-IPC-Cmd perl-IPC-SysV perl-IPC-System-Simple perl-JSON perl-JSON-PP perl-LWP-MediaTypes perl-LWP-Protocol-https perl-Locale-Codes perl-Locale-Maketext perl-Locale-Maketext-Simple perl-MRO-Compat perl-Math-BigInt perl-Math-BigInt-FastCalc perl-Math-BigRat perl-Math-Complex perl-Memoize perl-Module-Build perl-Module-CoreList perl-Module-CoreList-tools perl-Module-Load perl-Module-Load-Conditional perl-Module-Loaded perl-Module-Metadata perl-NTLM perl-Net-HTTP perl-Net-INET6Glue perl-Net-Ping perl-Package-Generator perl-Params-Check perl-Params-Util perl-Perl-OSType perl-PerlIO-via-QuotedPrint perl-Pod-Checker perl-Pod-Html perl-Pod-Parser perl-SelfLoader perl-Software-License perl-Sub-Exporter perl-Sub-Install perl-Sys-Syslog perl-Test perl-Test-Harness perl-Test-Simple perl-Text-Balanced perl-Text-Diff perl-Text-Glob perl-Text-Template perl-Thread-Queue perl-Time-HiRes perl-Time-Piece perl-TimeDate perl-Try-Tiny perl-Unicode-Collate perl-WWW-RobotRules perl-autodie perl-bignum perl-devel perl-encoding perl-experimental perl-inc-latest perl-libnetcfg perl-libwww-perl perl-local-lib perl-open perl-perlfaq perl-utils perl-version python3-pyparsing re2 slang systemtap-sdt-devel valgrind xxhash xxhash-libs && \
    dnf clean --enablerepo=* all

#$(if [[ -e /tmp/include/additional-packages.txt ]]; then echo $(cat /tmp/include/additional-packages.txt | xargs); fi) && \

RUN source /opt/rh/gcc-toolset-11/enable && \
    curl -O https://index.rubygems.org/gems/ffi-1.15.5.gem && \
    file ffi-1.15.5.gem && \
    tar xvf ffi-1.15.5.gem && \
    file metadata.gz && \
    gunzip metadata.gz && \
    file data.tar.gz && \
    gunzip data.tar.gz && \
    file data.tar && \
    tar xvf data.tar && \
    cd ext/ffi_c/ && \
    /usr/bin/ruby -I /usr/share/rubygems  extconf.rb  && \
    cat Makefile && \
    pwd && \
    tar zcvf $SD_ARTIFACTS_DIR/ffi.tgz . && \
    make --debug  && \
    rm -rf /tmp/include

# Java requires proper locale for unicode
ENV LANG en_US.UTF-8
