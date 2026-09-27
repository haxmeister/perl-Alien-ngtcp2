package Alien::ngtcp2;

use strict;
use warnings;
use parent 'Alien::Base';

our $VERSION = '0.02';

sub crypto_backend {
    my ($class) = @_;

    return $class->runtime_prop->{my_crypto_backend};
}

sub crypto_package {
    my ($class) = @_;

    return $class->runtime_prop->{my_crypto_package};
}

sub crypto_cflags {
    my ($class) = @_;

    my $flags
        = $class->alt($class->crypto_package)->cflags;

    if ($class->crypto_backend eq 'picotls'
        && $class->install_type eq 'share') {
        my $openssl
            = $class->runtime_prop->{my_openssl_cflags} || '';

        $flags = join ' ', grep { length } $flags, $openssl;
    }

    return $flags;
}

sub crypto_libs {
    my ($class) = @_;

    my $helper = $class->alt($class->crypto_package);

    if ($class->crypto_backend eq 'picotls'
        && $class->install_type eq 'share') {
        my $picotls = $class->runtime_prop->{my_picotls_libs} || '';
        my $openssl = $class->runtime_prop->{my_openssl_libs} || '';

        return join ' ', grep { length }
            $helper->libs,
            $picotls,
            $class->libs,
            $openssl;
    }

    return $helper->libs;
}

1;

__END__

=head1 NAME

Alien::ngtcp2 - Find or build ngtcp2 with a usable QUIC crypto provider

=head1 SYNOPSIS

    use Alien::ngtcp2;

    my $cflags = Alien::ngtcp2->cflags;
    my $libs   = Alien::ngtcp2->libs;

    my $backend       = Alien::ngtcp2->crypto_backend;
    my $crypto_cflags = Alien::ngtcp2->crypto_cflags;
    my $crypto_libs   = Alien::ngtcp2->crypto_libs;

=head1 DESCRIPTION

Alien::ngtcp2 provides C<libngtcp2> and a usable ngtcp2 QUIC crypto helper.

The inherited C<cflags> and C<libs> methods continue to describe the core
C<libngtcp2> library. This preserves the interface provided by version 0.01.

At installation time Alien::ngtcp2 first looks for a compatible system
C<libngtcp2> together with one of its crypto helpers. If such a pair is
available, it is reused.

The automatic system preference order is:

  libngtcp2_crypto_ossl
  libngtcp2_crypto_gnutls
  libngtcp2_crypto_boringssl
  libngtcp2_crypto_wolfssl
  libngtcp2_crypto_picotls

If no complete system pair is available, Alien::ngtcp2 builds the matching
ngtcp2 crypto integration from source. A host with a suitable GnuTLS
installation can use C<libngtcp2_crypto_gnutls>. Otherwise the normal fallback
builds ngtcp2 1.25.0 with the exact Picotls revision tested by that ngtcp2
release.

Picotls uses OpenSSL for cryptographic and X.509 operations but does not
require OpenSSL's QUIC TLS API. On Unix-like systems this fallback obtains
OpenSSL through L<Alien::OpenSSL>. Alien::OpenSSL prefers an existing system
installation and can provide a private copy when required.

On Windows the fallback uses the OpenSSL development tree belonging to the
active Perl/compiler toolchain. Picotls requires OpenSSL 1.1.1 or newer.
Older Windows toolchains are rejected with a clear diagnostic rather than
having their TLS installation silently replaced. Strawberry Perl 5.30 and
newer meet this baseline; Strawberry Perl 5.28 contains OpenSSL 1.1.0j and is
too old for the fallback.

Alien::ngtcp2 never replaces or upgrades the operating system TLS library.

=head1 UPSTREAM VERSION

This release accepts compatible system C<libngtcp2> and crypto helper
installations at version 1.25.0 or newer. Its source builds use ngtcp2
1.25.0.

=head1 PERL VERSION

Alien::ngtcp2 requires Perl 5.20 or newer.

The Perl version requirement is independent of the native TLS requirement.
For example, Perl 5.28 works with a current native toolchain even though the
historical Strawberry Perl 5.28 distribution bundles an OpenSSL release that
is too old for the Picotls fallback.

=head1 METHODS

=head2 cflags

=head2 libs

The inherited L<Alien::Base> methods describe core C<libngtcp2> only.

=head2 crypto_backend

Returns the selected crypto backend name, such as C<openssl>, C<gnutls>,
C<boringssl>, C<wolfssl>, or C<picotls>.

=head2 crypto_package

Returns the selected ngtcp2 crypto helper pkg-config package name.

=head2 crypto_cflags

Returns the compiler flags needed by a consumer of the selected crypto helper.

=head2 crypto_libs

Returns the linker flags needed by a consumer of the selected crypto helper
and its TLS implementation.

=head1 BACKEND OVERRIDE

Most users should allow automatic selection.

Developers and packagers may set C<ALIEN_NGTCP2_CRYPTO> to C<auto> or one of:

  openssl
  gnutls
  boringssl
  wolfssl
  picotls

An explicit backend choice first uses a matching system C<libngtcp2> crypto
helper when available. C<gnutls> and C<openssl> can also build the matching
ngtcp2 helper when a suitable raw system TLS library is present. C<picotls>
explicitly selects the portable source fallback.

=head1 FALLBACK PICOTLS SOURCE

The fallback contains the MIT-licensed Picotls TLS core and OpenSSL binding
from commit:

  f07f1c8c68b237f1468bc1f1fe1b68aba3ff23b4

This is the Picotls revision documented by ngtcp2 1.25.0.

The Picotls minicrypto backend and its third-party dependencies are not
included or built.

=head1 SEE ALSO

L<Alien::Base>

L<Alien::OpenSSL>

L<https://github.com/ngtcp2/ngtcp2>

L<https://github.com/h2o/picotls>

=head1 AUTHOR

Joshua S. Day

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2026 by Joshua S. Day.

This is free software, licensed under:

    The MIT (X11) License

=cut
