#!/usr/bin/env bash
source /root/build-defines.sh
cd /root
tar xzf /pcre2-${PCRE_VERSION}.tar.gz
cd pcre2-${PCRE_VERSION}
./configure --enable-jit --prefix=/opt
make -j$(nproc)
make install
