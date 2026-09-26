# Alien::ngtcp2

Alien::ngtcp2 finds or builds the native ngtcp2 QUIC transport library for
Perl distributions.

It is deliberately independent of any Perl QUIC implementation, HTTP/3
implementation, TLS backend, or event loop.

## Compatibility

Alien::ngtcp2 targets Perl 5.16 and newer.

The source-build path is tested on Linux and macOS, with Windows using the
standard Alien::Build CMake integration. The bundled native library requires a
C11-capable compiler.

## Behavior

If pkg-config can find libngtcp2 1.25.0 or newer, Alien::ngtcp2 uses that
system installation.

Otherwise it downloads ngtcp2 1.25.0 and builds a private static copy of the
core libngtcp2 library.

The fallback build does not include ngtcp2 crypto helper libraries or the
example applications.

## Use from another Perl distribution

Consumers use the normal Alien::Base interface:

    use Alien::ngtcp2;

    my $cflags = Alien::ngtcp2->cflags;
    my $libs   = Alien::ngtcp2->libs;

For XS distributions, the usual Alien::Base / Alien::Build integration can use
those flags during compilation and linking.

## Development

    perl Makefile.PL
    make
    make test

Set ALIEN_INSTALL_TYPE=share to force the bundled source-build path when
testing it:

    ALIEN_INSTALL_TYPE=share perl Makefile.PL
    make
    make test

Set ALIEN_INSTALL_TYPE=system to require a suitable system installation.

## License

MIT
