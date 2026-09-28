# Alien::ngtcp2 handoff

## Current branch

feature/picotls-only

Base release: 0.02

Release candidate version: 0.03

main remains the released 0.02 code.

## Current direction

Alien::ngtcp2 now has one QUIC TLS backend:

    ngtcp2 1.25.0
        |
        +-- libngtcp2_crypto_picotls
                |
                +-- Picotls
                        |
                        +-- OpenSSL crypto

The bundled Picotls revision is:

    f07f1c8c68b237f1468bc1f1fe1b68aba3ff23b4

This is the revision documented by ngtcp2 1.25.0.

## Why this changed

Version 0.02 could select OpenSSL, GnuTLS, BoringSSL, wolfSSL, or Picotls.

That flexibility pushed all of those different TLS APIs into Net::QUIC.

Net::QUIC only needs one dependable TLS implementation. Picotls is small,
MIT licensed, designed for TLS 1.3 and QUIC, and already worked through the
Alien fallback on Linux, macOS, and Windows.

ngtcp2's native OpenSSL helper is still documented as experimental and needs
OpenSSL 3.5 or newer.

GnuTLS is mature but expensive to provide as a portable bundled dependency.

AWS-LC is a strong option but much heavier to build.

wolfSSL's GPLv3/commercial licensing is a poor default dependency for an MIT
Perl transport library.

## Deterministic native pair

Alien::ngtcp2 no longer selects an arbitrary installed ngtcp2 TLS helper.

A system libngtcp2_crypto_picotls pkg-config file records the ngtcp2 version,
but it does not record which Picotls revision it was built against.

For that reason this branch always source-builds the tested ngtcp2/Picotls
pair.

The host still supplies OpenSSL when suitable.

## OpenSSL policy

Picotls uses OpenSSL for crypto and X.509 handling.

On Unix-like systems:

- use system OpenSSL 1.1.1 or newer when available;
- otherwise use Alien::OpenSSL.

On Windows:

- use the OpenSSL development tree associated with the active Perl/compiler;
- reject OpenSSL older than 1.1.1;
- do not silently install a second TLS stack.

Historical Strawberry Perl 5.28 remains an intentional rejection because it
contains OpenSSL 1.1.0j.

## Public API

These methods remain available:

    Alien::ngtcp2->cflags
    Alien::ngtcp2->libs
    Alien::ngtcp2->crypto_backend
    Alien::ngtcp2->crypto_package
    Alien::ngtcp2->crypto_cflags
    Alien::ngtcp2->crypto_libs

The fixed values are now:

    crypto_backend = picotls
    crypto_package = libngtcp2_crypto_picotls

Keeping the methods avoids an unnecessary downstream API break from 0.02.

The ALIEN_NGTCP2_CRYPTO backend-selection environment variable is removed.

## CI

The branch keeps:

- Linux Perl 5.20 through 5.44, every even minor;
- macOS Perl 5.20, 5.28, 5.36, 5.44;
- Windows Perl 5.20, 5.28, 5.36, 5.44;
- Strawberry Perl 5.30 and 5.42;
- legacy Strawberry Perl 5.28 rejection diagnostic;
- minimum Alien::Build 2.84 on Linux and Windows;
- disttest and CPANTS on Linux Perl 5.44.

The old GnuTLS/OpenSSL/provider-selection CI jobs were removed because those
backends are no longer part of the contract.

## Next steps

1. Get the final 0.03 commit through the full CI matrix.
2. Merge feature/picotls-only to main when that final matrix is green.
3. Build and upload Alien-ngtcp2-0.03.tar.gz to PAUSE.
4. Tag/create the GitHub 0.03 release after the release artifact is confirmed.
5. Update Net::QUIC to require Alien::ngtcp2 0.03 and remove all non-Picotls TLS code.
