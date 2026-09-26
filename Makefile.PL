use strict;
use warnings;

use Alien::Build::MM;
use ExtUtils::MakeMaker;

my $abmm = Alien::Build::MM->new;

WriteMakefile(
    $abmm->mm_args(
        NAME             => 'Alien::ngtcp2',
        DISTNAME         => 'Alien-ngtcp2',
        VERSION_FROM     => 'lib/Alien/ngtcp2.pm',
        ABSTRACT_FROM    => 'lib/Alien/ngtcp2.pm',
        AUTHOR           => 'Joshua S. Day <haxmeister@hotmail.com>',
        LICENSE          => 'mit',
        MIN_PERL_VERSION => '5.016',

        CONFIGURE_REQUIRES => {
            'Alien::Build::MM' => '2.88',
        },

        BUILD_REQUIRES => {
            'Alien::Build::MM' => '2.88',
        },

        PREREQ_PM => {
            'Alien::Base' => '2.88',
            'HTTP::Tiny'   => '0.044',
            'URI'          => 0,
        },

        TEST_REQUIRES => {
            'Test2::V0'   => 0,
            'Test::Alien' => '2.88',
        },

        META_MERGE => {
            'meta-spec' => {
                version => 2,
            },
            resources => {
                homepage => 'https://github.com/haxmeister/perl-Alien-ngtcp2',
                repository => {
                    type => 'git',
                    url  => 'https://github.com/haxmeister/perl-Alien-ngtcp2.git',
                    web  => 'https://github.com/haxmeister/perl-Alien-ngtcp2',
                },
                bugtracker => {
                    web => 'https://github.com/haxmeister/perl-Alien-ngtcp2/issues',
                },
            },
        },
    )
);

sub MY::postamble {
    return $abmm->mm_postamble;
}
