#!/usr/bin/env bash
source /root/build-defines.sh
cd /root
tar xzf /v${ZLIB_VERSION}.tar.gz
cd zlib-${ZLIB_VERSION}
./configure --static --prefix=/opt
make -j$(nproc)
make test
make install
