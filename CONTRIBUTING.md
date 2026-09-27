# Contributing to Alien::ngtcp2

Contributions are welcome through the GitHub repository:

https://github.com/haxmeister/perl-Alien-ngtcp2

## Reporting bugs

Please open an issue and include enough information to reproduce the problem.

Useful details are:

- operating system
- Perl version
- Alien::Build version
- compiler version when relevant
- the output from `perl Makefile.PL`
- the output from `make` or `make test`

If the problem is about which TLS library was selected, also include:

    pkgconf --modversion openssl
    pkgconf --modversion gnutls

Run whichever command applies on your system.

For security issues, follow SECURITY.md instead of opening a public issue.

## Development

Alien::ngtcp2 requires Perl 5.20 or newer and Alien::Build 2.84 or newer.

A normal development build is:

    perl Makefile.PL
    make
    make test

To force a source build of ngtcp2:

    ALIEN_INSTALL_TYPE=share perl Makefile.PL
    make
    make test

To require an already-installed system ngtcp2:

    ALIEN_INSTALL_TYPE=system perl Makefile.PL
    make
    make test

To force a particular TLS backend while testing:

    ALIEN_NGTCP2_CRYPTO=openssl perl Makefile.PL
    ALIEN_NGTCP2_CRYPTO=gnutls perl Makefile.PL
    ALIEN_NGTCP2_CRYPTO=picotls perl Makefile.PL

Most users should not set this variable.

Before submitting a pull request, make sure the test suite passes.

Changes to the native build path should keep working on the supported Linux,
macOS, and Windows configurations.

## Scope

Alien::ngtcp2 supplies the native pieces needed by a Perl QUIC library:

- libngtcp2
- one usable ngtcp2 TLS/crypto helper

It does not provide a Perl QUIC connection API, HTTP/3, UDP socket handling, or
an event loop. Those belong in higher-level distributions such as Net::QUIC.
