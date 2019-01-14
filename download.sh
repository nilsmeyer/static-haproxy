#!/usr/bin/env bash

openssl_key_id=8657ABB260F056B1E5190839D9C4D26D0E604491
pcre_key_id=FB0F43D8
pcre_key_fp=45F68D54BBE23FB3039B46E59766E084FB0F43D8
echo $GLOBAL_CFLAGS
echo $zlib
echo $cpu

# Seperate version number into major, minor, patch
IFS="." read -ra hap_v <<< "$HAPROXY_VERSION"

function exerr {
	echo $*
	exit 1
}

echo "importing openssl key from keyserver"
gpg2 --keyserver keyserver.ubuntu.com --recv ${openssl_key_id}
echo "importing pcre2 key from keyserver"
gpg2 --keyserver keyserver.ubuntu.com --recv ${pcre_key_id}

if [ "${zlib}" == "cloudflare" ]
then
	zlib_url="https://github.com/cloudflare/zlib/archive/v${ZLIB_VERSION}.tar.gz"
fi
wget $zlib_url || exerr "Unable to download zlib from $zlib_url"

wget https://ftp.pcre.org/pub/pcre/pcre2-${PCRE_VERSION}.tar.gz || exerr unable to download pcre2
wget https://ftp.pcre.org/pub/pcre/pcre2-${PCRE_VERSION}.tar.gz.sig || exerr unable to download pcre2 sig

gpg_verfiy=$(gpg2 --verify pcre2-${PCRE_VERSION}.tar.gz.sig pcre2-${PCRE_VERSION}.tar.gz)

if [ "$?" -ne "0" ]
then
	echo "Can't verify PCRE2 signature"
	echo $gpg_verify
	exit 1
fi

echo "Downloading HAProxy"
wget http://www.haproxy.org/download/${hap_v[0]}.${hap_v[1]}/src/haproxy-${HAPROXY_VERSION}.tar.gz || exerr "Unable to download HAProxy"

csum_haproxy=$(curl -s "https://www.haproxy.org/download/${hap_v[0]}.${hap_v[1]}/src/haproxy-${HAPROXY_VERSION}.tar.gz.sha256")
csum_file=$(sha256sum haproxy-${HAPROXY_VERSION}.tar.gz)

if [ "$csum_file" != "$csum_haproxy" ]
then
	echo "Checksums for HAProxy do not match"
	echo $csum_file
	echo $csum_haproxy
	exit 1
fi

echo "Downloading OpenSSL"
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz || exerr "unable to download openssl"

echo "Downloading OpenSSL signature"
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.asc
gpg_verfiy=$(gpg2 --verify openssl-${OPENSSL_VERSION}.tar.gz.asc openssl-${OPENSSL_VERSION}.tar.gz)

if [ "$?" -ne "0" ]
then
	echo "Can't verify OpenSSL signature"
	echo $gpg_verify
	cat openssl-${OPENSSL_VERSION}.tar.gz.asc
	exit 1
fi


