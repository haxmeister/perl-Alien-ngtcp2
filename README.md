# Alien::ngtcp2

[![CI](https://github.com/haxmeister/perl-Alien-ngtcp2/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/haxmeister/perl-Alien-ngtcp2/actions/workflows/test.yml)
[![Perl](https://img.shields.io/badge/perl-5.20%2B-blue.svg)](https://www.perl.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![ngtcp2](https://img.shields.io/badge/ngtcp2-1.25.0%2B-blue.svg)](https://github.com/ngtcp2/ngtcp2)

Alien::ngtcp2 finds or builds the native ngtcp2 libraries needed by Perl QUIC
modules.

Most users do not need to choose a TLS library. Alien::ngtcp2 checks the
machine and uses a suitable one automatically.

## What gets installed

QUIC needs two native pieces:

- libngtcp2, which handles the QUIC protocol
- an ngtcp2 TLS helper, which connects ngtcp2 to a TLS library

If both pieces are already installed and compatible, Alien::ngtcp2 uses them.

If ngtcp2 must be built from source, Alien::ngtcp2 uses the TLS software
already on the machine when possible:

1. OpenSSL 3.5 or newer -> build the ngtcp2 OpenSSL helper
2. otherwise GnuTLS 3.7.5 or newer -> build the ngtcp2 GnuTLS helper
3. otherwise OpenSSL 1.1.1 through 3.4 -> use Picotls with that OpenSSL
4. if no suitable TLS library exists on Unix -> Alien::OpenSSL can provide a
   private OpenSSL for the Picotls fallback

On Windows, the fallback uses the OpenSSL that belongs to the active Perl and
compiler toolchain. Old Windows toolchains with OpenSSL older than 1.1.1 are
rejected instead of silently installing a different TLS stack.

Alien::ngtcp2 does not replace or upgrade the operating system TLS library.

## Using it from another Perl distribution

The original interface still describes the core libngtcp2 library:

    use Alien::ngtcp2;

    my $cflags = Alien::ngtcp2->cflags;
    my $libs   = Alien::ngtcp2->libs;

A QUIC distribution can also ask for the selected TLS helper:

    my $backend       = Alien::ngtcp2->crypto_backend;
    my $crypto_cflags = Alien::ngtcp2->crypto_cflags;
    my $crypto_libs   = Alien::ngtcp2->crypto_libs;

`crypto_backend` returns a short name such as `openssl`, `gnutls`, or
`picotls`.

A normal Net::QUIC user should not need to call any of these methods or choose
a backend.

## Expert override

Packagers and developers can force a backend with `ALIEN_NGTCP2_CRYPTO`:

    auto
    openssl
    gnutls
    boringssl
    wolfssl
    picotls

Most users should leave this unset.

## Compatibility

Alien::ngtcp2 requires:

- Perl 5.20 or newer
- Alien::Build 2.84 or newer
- libngtcp2 1.25.0 or newer when using a system copy

The bundled ngtcp2 source is version 1.25.0.

Perl 5.28 itself is supported. Historical Strawberry Perl 5.28 is a special
case because its bundled OpenSSL 1.1.0j is too old for the Picotls fallback.
Strawberry Perl 5.30 and newer meet the required TLS baseline.

## Development

    perl Makefile.PL
    make
    make test

To force the complete Picotls fallback while developing:

    ALIEN_INSTALL_TYPE=share ALIEN_NGTCP2_CRYPTO=picotls perl Makefile.PL
    make
    make test

See CONTRIBUTING.md for more development information.

## License

Alien::ngtcp2 is MIT licensed.

The bundled Picotls source subset is also MIT licensed and keeps its upstream
copyright and license notices.
