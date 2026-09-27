use strict;
use warnings;

use Test2::V0;
use Alien::ngtcp2;

my $backend = Alien::ngtcp2->crypto_backend;

ok(
    defined($backend) && length($backend),
    'crypto backend is selected',
);

like(
    Alien::ngtcp2->crypto_package,
    qr/^libngtcp2_crypto_/,
    'crypto helper package is identified',
);

ok(
    length(Alien::ngtcp2->crypto_cflags),
    'crypto compiler flags are available',
);

ok(
    length(Alien::ngtcp2->crypto_libs),
    'crypto linker flags are available',
);

if (Alien::ngtcp2->install_type eq 'share') {
    is(
        $backend,
        'picotls',
        'share fallback uses Picotls',
    );
}

done_testing;
