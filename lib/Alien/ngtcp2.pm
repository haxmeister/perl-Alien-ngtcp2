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

Alien::ngtcp2 - Find or build the native libraries needed for QUIC

=head1 SYNOPSIS

    use Alien::ngtcp2;

    my $cflags = Alien::ngtcp2->cflags;
    my $libs   = Alien::ngtcp2->libs;

    my $backend       = Alien::ngtcp2->crypto_backend;
    my $crypto_cflags = Alien::ngtcp2->crypto_cflags;
    my $crypto_libs   = Alien::ngtcp2->crypto_libs;

=head1 DESCRIPTION

Alien::ngtcp2 supplies the native ngtcp2 libraries needed by Perl QUIC
distributions.

QUIC needs two native pieces:

=over 4

=item * C<libngtcp2>, which handles the QUIC protocol

=item * an ngtcp2 TLS helper, which connects ngtcp2 to a TLS library

=back

Most users do not need to choose a TLS library. Alien::ngtcp2 checks the
machine and uses a suitable one automatically.

The original C<cflags> and C<libs> methods still describe only the core
C<libngtcp2> library. This keeps the interface from version 0.01 working.

=head1 HOW INSTALLATION WORKS

If a compatible C<libngtcp2> and TLS helper are already installed,
Alien::ngtcp2 uses them.

If ngtcp2 must be built from source, Alien::ngtcp2 tries to use TLS software
already on the machine:

=over 4

=item 1. OpenSSL 3.5 or newer

Build the ngtcp2 OpenSSL helper.

=item 2. Otherwise, GnuTLS 3.7.5 or newer

Build the ngtcp2 GnuTLS helper.

=item 3. Otherwise, OpenSSL 1.1.1 through 3.4

Use Picotls with that existing OpenSSL.

=item 4. No suitable TLS library on Unix

L<Alien::OpenSSL> can provide a private OpenSSL for the Picotls fallback.

=back

Alien::ngtcp2 does not replace or upgrade the operating system TLS library.

=head2 Windows

On Windows the fallback uses the OpenSSL that belongs to the active Perl and
compiler toolchain.

If that OpenSSL is older than 1.1.1, installation stops with a clear error
instead of silently installing a different TLS stack.

Strawberry Perl 5.30 and newer meet this requirement. Historical Strawberry
Perl 5.28 contains OpenSSL 1.1.0j and is too old for the fallback.

=head1 METHODS

=head2 cflags

Returns compiler flags for the core C<libngtcp2> library.

=head2 libs

Returns linker flags for the core C<libngtcp2> library.

=head2 crypto_backend

Returns the selected TLS backend name, such as C<openssl>, C<gnutls>,
C<boringssl>, C<wolfssl>, or C<picotls>.

=head2 crypto_package

Returns the pkg-config package name for the selected ngtcp2 TLS helper.

=head2 crypto_cflags

Returns the compiler flags needed to use the selected ngtcp2 TLS helper.

=head2 crypto_libs

Returns the linker flags needed to use the selected ngtcp2 TLS helper.

=head1 BACKEND OVERRIDE

Most users should let Alien::ngtcp2 choose automatically.

Packagers and developers may set C<ALIEN_NGTCP2_CRYPTO> to C<auto> or one of:

  openssl
  gnutls
  boringssl
  wolfssl
  picotls

An explicit choice is mainly useful for testing and packaging.

=head1 VERSIONS

Alien::ngtcp2 requires Perl 5.20 or newer and Alien::Build 2.84 or newer.

A system C<libngtcp2> must be version 1.25.0 or newer.

The bundled ngtcp2 source is version 1.25.0.

=head1 BUNDLED PICOTLS SOURCE

The Picotls fallback contains the MIT-licensed Picotls TLS core and OpenSSL
binding from commit:

  f07f1c8c68b237f1468bc1f1fe1b68aba3ff23b4

That is the Picotls revision documented by ngtcp2 1.25.0.

The Picotls minicrypto backend and its third-party dependencies are not
included.

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
