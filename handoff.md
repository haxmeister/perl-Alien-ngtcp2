# Alien::ngtcp2 handoff

## Current branch

feature/crypto-provider-selection

Draft PR: #4

Development version: 0.02_01

Base release: 0.01

## Purpose of this branch

Alien::ngtcp2 0.01 intentionally provided only core libngtcp2.

While designing Net::QUIC we determined that a complete QUIC connection also
needs one of ngtcp2's TLS/crypto helper libraries. The community-facing goal is
that Net::QUIC should install into Linux::Event, IO::Async, PAGI, or another
Perl ecosystem without forcing that ecosystem to replace or reorganize its TLS
stack.

The rule for this branch is:

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

A system provider is accepted only together with libngtcp2 1.25.0 or newer.

Expert override:

    ALIEN_NGTCP2_CRYPTO=auto
    ALIEN_NGTCP2_CRYPTO=openssl
    ALIEN_NGTCP2_CRYPTO=gnutls
    ALIEN_NGTCP2_CRYPTO=boringssl
    ALIEN_NGTCP2_CRYPTO=wolfssl
    ALIEN_NGTCP2_CRYPTO=picotls

## Source fallback

The normal source fallback builds:

    ngtcp2 1.25.0
    libngtcp2_crypto_picotls
    pinned Picotls commit
      f07f1c8c68b237f1468bc1f1fe1b68aba3ff23b4

Only the MIT-licensed Picotls TLS core and OpenSSL binding are vendored. The
minicrypto dependency tree is not included.

Picotls handles TLS 1.3. OpenSSL is used for crypto and X.509 operations; this
path does not require OpenSSL 3.5's native QUIC TLS API.

On Unix-like systems OpenSSL is obtained through Alien::OpenSSL, which prefers
the existing system installation and can provide a private fallback.

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

## CI status at this handoff update

Before the final documentation/system-provider commits, the Picotls fallback
was green on:

- Linux Perl 5.20 through 5.44;
- Windows Perl 5.20, 5.28, 5.36, 5.44;
- minimum Alien::Build 2.84 on Linux and Windows;
- Strawberry Perl 5.42.

The old Strawberry 5.28 failure was traced to its bundled OpenSSL 1.1.0j and
was converted into an intentional diagnostic test.

The final matrix including Strawberry 5.30 and the system-GnuTLS reuse job
must be green before merging PR #4.

## Next steps

1. Wait for the final CI matrix after the latest branch commits.
2. Fix any real portability/provider-reuse failures.
3. Do not merge until fallback and system-provider paths are both green.
4. Once Alien::ngtcp2 is stable, update Net::QUIC to require the new Alien
   version and consume crypto_backend/crypto_cflags/crypto_libs.
5. Net::QUIC remains event-loop neutral: frameworks own UDP sockets, readiness,
   scheduling, and timers; Net::QUIC owns QUIC/TLS protocol state.
