#! /usr/bin/perl

use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new (
     module_name => 'DNS::ZoneEdit',
     dist_author => 'Evan Giles <egiles@cpan.org>',
     license  => 'perl',
     requires => {
        'perl'            => '5.6.1',
        'LWP::UserAgent'  => 2.001,
     },
     create_makefile_pl => 'traditional',
     meta_merge     => {
       resources => {
         repository => 'http://github.com/egiles/dns-zoneedit',
       }
     },
     add_to_cleanup => [ 'Makefile.PL', 'META.yml' ],
);
$build->create_build_script;