# Alien::ngtcp2

[![CI](https://github.com/haxmeister/perl-Alien-ngtcp2/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/haxmeister/perl-Alien-ngtcp2/actions/workflows/test.yml)
[![Perl](https://img.shields.io/badge/perl-5.20%2B-blue.svg)](https://www.perl.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![ngtcp2](https://img.shields.io/badge/ngtcp2-1.25.0%2B-blue.svg)](https://github.com/ngtcp2/ngtcp2)

Alien::ngtcp2 finds or builds the native ngtcp2 QUIC transport library for
Perl distributions.

It also makes a usable ngtcp2 QUIC crypto helper available without requiring
ordinary Perl users to choose a TLS implementation.

## Crypto provider policy

Installation is automatic.

If a compatible system ngtcp2 crypto helper is already installed,
Alien::ngtcp2 reuses it. The current preference order is:

1. OpenSSL
2. GnuTLS
3. BoringSSL / AWS-LC
4. wolfSSL
5. Picotls

If no complete system pair is present, the share build uses the Picotls
revision tested by ngtcp2 1.25.0. That fallback uses OpenSSL for cryptographic
and X.509 operations, but does not require OpenSSL 3.5's QUIC TLS API.

OpenSSL is obtained through Alien::OpenSSL. Alien::OpenSSL first reuses an
existing system installation and only supplies a private copy when the machine
does not already provide one.

Alien::ngtcp2 never replaces or upgrades the operating system TLS library.

## Consumer interface

The original core interface remains unchanged:

    use Alien::ngtcp2;

    my $core_cflags = Alien::ngtcp2->cflags;
    my $core_libs   = Alien::ngtcp2->libs;

Consumers that need complete QUIC connection support can additionally use:

    my $backend      = Alien::ngtcp2->crypto_backend;
    my $crypto_flags = Alien::ngtcp2->crypto_cflags;
    my $crypto_libs  = Alien::ngtcp2->crypto_libs;

A normal Net::QUIC user should not need to select or understand the backend.

## Expert override

Packagers and developers can set ALIEN_NGTCP2_CRYPTO to:

    auto
    openssl
    gnutls
    boringssl
    wolfssl
    picotls

Except for picotls, an explicit choice currently requires a matching system
ngtcp2 crypto helper.

## Compatibility

Alien::ngtcp2 targets Perl 5.20 and newer and requires Alien::Build 2.84 or
newer.

The bundled ngtcp2 version is 1.25.0.

## Development

    perl Makefile.PL
    make
    make test

Force the complete fallback path with:

    ALIEN_INSTALL_TYPE=share ALIEN_NGTCP2_CRYPTO=picotls perl Makefile.PL
    make
    make test

## License

MIT

The bundled Picotls source subset is MIT-licensed and retains its upstream
copyright and license notices.
