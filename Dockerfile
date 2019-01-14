FROM fedora:latest AS fedora-buildenv
ARG cpu=haswell
ARG zlib=cloudflare
ENV GLOBAL_CFLAGS="-flto -march=$cpu -O3 -fuse-linker-plugin -fuse-ld=gold"
ENV OPENSSL_VERSION=1.1.1a
ENV PCRE_VERSION=10.32
ENV ZLIB_VERSION=1.2.8 
ENV HAPROXY_VERSION=1.9.1
RUN yum -y groups install rpm-development-tools development-tools && \
    yum -y install wget glibc-static && \
    true
COPY download.sh /root/
RUN zlib="${zlib}" /root/download.sh
COPY build-defines.sh build-zlib.sh build-openssl.sh build-pcre.sh build-haproxy.sh /root/
RUN zlib="${zlib}" /root/build-zlib.sh
RUN /root/build-openssl.sh
RUN /root/build-pcre.sh
RUN mkdir -p /root/rpmbuild/SPECS /root/rpmbuild/SOURCES && \
    mv /haproxy-${HAPROXY_VERSION}.tar.gz /root/rpmbuild/SOURCES
COPY haproxy.spec /root/rpmbuild/SPECS
RUN sed -i \
    -e "s/__version__/$HAPROXY_VERSION/g" \ 
    -e "s/__cflags__/$GLOBAL_CFLAGS/g" \
    -e "s/__cpu__/$cpu/g" \
    /root/rpmbuild/SPECS/haproxy.spec && \
    rpmbuild -ba /root/rpmbuild/SPECS/haproxy.spec && \
    mv /root/rpmbuild/BUILD/haproxy-${HAPROXY_VERSION}/haproxy /

FROM scratch
COPY --from=fedora-buildenv /haproxy /
ENTRYPOINT ["/haproxy"]
