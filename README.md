# Static HAProxy docker builder

This builds a statically linked HAProxy, including downloading and building
OpenSSL 1.1.1a, cloudflare optimized zlib and PCRE2, with CPU optimization
for Haswell and LTO. It builds on Fedora also producing a RPM, however the
RPM doesn't include systemd sd_notify support for lack of a static libsystemd.

The resulting container just includes the binary, no shell etc. for reduced
attack surface.
