# Alien::ngtcp2 handoff

## Current branch

main

Current release-ready version: 0.02

Previous CPAN release: 0.01

Release preparation PRs: #5, #6, and #7 (merged)
Final documentation/CI polish PR: #8

## Purpose of release 0.02

Alien::ngtcp2 0.01 intentionally provided only core libngtcp2.

While designing Net::QUIC we determined that a complete QUIC connection also
needs one of ngtcp2's TLS/crypto helper libraries. The community-facing goal is
that Net::QUIC should install into Linux::Event, IO::Async, PAGI, or another
Perl ecosystem without forcing that ecosystem to replace or reorganize its TLS
stack.

The release rule is:

    Adapt to the host TLS ecosystem. Do not make the host adapt to us.

## Public compatibility contract

The original interface remains core-only:

    Alien::ngtcp2->cflags
    Alien::ngtcp2->libs

New methods describe the selected QUIC crypto provider:

    Alien::ngtcp2->crypto_backend
    Alien::ngtcp2->crypto_package
    Alien::ngtcp2->crypto_cflags
    Alien::ngtcp2->crypto_libs

Net::QUIC should consume these methods and should not expose normal users to
backend-specific Perl objects.

## Provider selection

Automatic system preference order:

1. libngtcp2_crypto_ossl
2. libngtcp2_crypto_gnutls
3. libngtcp2_crypto_boringssl
4. libngtcp2_crypto_wolfssl
5. libngtcp2_crypto_picotls

The automatic policy is host TLS first. Picotls is the compatibility fallback,
not a replacement for a suitable TLS provider already present on the host.

A system provider is accepted only together with libngtcp2 1.25.0 or newer.

Expert override:

    ALIEN_NGTCP2_CRYPTO=auto
    ALIEN_NGTCP2_CRYPTO=openssl
    ALIEN_NGTCP2_CRYPTO=gnutls
    ALIEN_NGTCP2_CRYPTO=boringssl
    ALIEN_NGTCP2_CRYPTO=wolfssl
    ALIEN_NGTCP2_CRYPTO=picotls

## Source fallback

If no complete system ngtcp2/provider pair exists:

1. OpenSSL 3.5 or newer builds libngtcp2_crypto_ossl.
2. Otherwise GnuTLS 3.7.5 or newer builds libngtcp2_crypto_gnutls.
3. Otherwise OpenSSL 1.1.1 through 3.4 uses the compatibility fallback:

       ngtcp2 1.25.0
       libngtcp2_crypto_picotls
       pinned Picotls commit
         f07f1c8c68b237f1468bc1f1fe1b68aba3ff23b4

4. If no suitable host TLS stack exists, Alien::OpenSSL supplies the private
   OpenSSL used by the same Picotls fallback.

Only the MIT-licensed Picotls TLS core and OpenSSL binding are vendored. The
minicrypto dependency tree is not included.

Picotls handles TLS 1.3. OpenSSL is used for crypto and X.509 operations; this
path does not require OpenSSL 3.5's native QUIC TLS API.

On Unix-like systems a suitable system OpenSSL 1.1.1 or newer is consumed
directly through pkg-config. Alien::OpenSSL is only required when no usable
system OpenSSL development installation is available; it then provides the
private fallback.

On Windows the fallback deliberately uses the OpenSSL development tree attached
to the active Perl/compiler toolchain instead of installing another OpenSSL.

Picotls/ngtcp2 require OpenSSL 1.1.1 or newer. Historical Strawberry Perl 5.28
contains OpenSSL 1.1.0j, so that specific distribution is rejected with a clear
diagnostic. Perl 5.28 itself remains supported and is tested on a current
Windows toolchain. Strawberry Perl 5.30 and newer meet the native baseline.

Do not weaken the requirement to OpenSSL 1.1.0 merely to make legacy CI green.

## Windows implementation notes

The Windows fallback:

- discovers the OpenSSL root from the active Perl/compiler environment;
- uses forward-slash paths when passing libraries to CMake;
- adds the static OpenSSL Windows link closure when needed;
- selects the MinGW Makefiles generator when Perl uses GCC/MinGW;
- adapts Picotls's upstream Windows compatibility shim for MinGW;
- disables Picotls's optional OpenSSL async-signing block on Windows.

The static Windows OpenSSL link closure currently includes:

    ssl
    crypto
    ws2_32
    gdi32
    advapi32
    crypt32
    user32
    z

## Tests

t/30-crypto-provider.t verifies provider metadata.

t/35-crypto-xs.t is the important downstream contract test. It uses
Alien::ngtcp2->crypto_cflags and ->crypto_libs to compile and link an actual XS
extension against ngtcp2_crypto.h.

The CI matrix tests:

- Linux Perl 5.20 through 5.44, every even minor in that range;
- macOS Perl 5.20, 5.28, 5.36, 5.44;
- Windows Perl 5.20, 5.28, 5.36, 5.44;
- Strawberry Perl 5.30 and 5.42;
- a legacy Strawberry Perl 5.28 diagnostic check;
- minimum Alien::Build 2.84 on Linux and Windows;
- a dedicated system-GnuTLS provider reuse job.

The GnuTLS job builds ngtcp2 1.25.0 against Ubuntu's GnuTLS, forces
ALIEN_INSTALL_TYPE=system, and must verify:

    Alien::ngtcp2->install_type eq 'system'
    Alien::ngtcp2->crypto_backend eq 'gnutls'

It then runs the same XS linkage test.

## CI status

The adaptive-provider implementation and host-TLS-first policy were validated
with the full matrix:

- Linux Perl 5.20 through 5.44;
- macOS Perl 5.20, 5.28, 5.36, 5.44;
- Windows Perl 5.20, 5.28, 5.36, 5.44;
- Strawberry Perl 5.30 and 5.42;
- minimum Alien::Build 2.84 on Linux and Windows;
- legacy Strawberry Perl 5.28 rejection diagnostic;
- system GnuTLS provider reuse;
- source-built GnuTLS helper;
- OpenSSL before 3.5 using the Picotls compatibility fallback;
- OpenSSL 3.5.7 using the native ngtcp2 OpenSSL helper;
- downstream XS compile/link through crypto_cflags and crypto_libs.

The 0.02 disttest and CPANTS lint passed before the final documentation polish.
PR #8 reruns those release checks after simplifying the public documentation
and correcting the general fallback CI matrix.

## Next steps

1. Build Alien-ngtcp2-0.02.tar.gz from main.
2. Upload the 0.02 tarball to PAUSE.
3. Tag/create the GitHub 0.02 release after the release artifact is confirmed.
4. Update Net::QUIC to require Alien::ngtcp2 0.02 and consume
   crypto_backend/crypto_cflags/crypto_libs.
5. Net::QUIC remains event-loop neutral: frameworks own UDP sockets, readiness,
   scheduling, and timers; Net::QUIC owns QUIC/TLS protocol state.
