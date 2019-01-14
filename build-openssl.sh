#!/usr/bin/env bash
source /root/build-defines.sh
cd /root
tar xzf /openssl-${OPENSSL_VERSION}.tar.gz
cd openssl-${OPENSSL_VERSION}
./config --prefix=/opt --openssldir=/opt no-shared
make -j$(nproc)
make install
