require 5.6.0;

use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'          => 'DNS::ZoneEdit',
    'ABSTRACT'      => 'Update your ZoneEdit dynamic DNS records',
    'AUTHOR'        => 'Evan Giles <egiles@cpan.org>',
    'PREREQ_PM'     => { 'LWP::UserAgent' => 2.001, 'HTTP::Request::Common' => 1.19 },
    'VERSION_FROM'  => 'lib/DNS/ZoneEdit.pm',
    'dist'          => { COMPRESS=>'gzip', SUFFIX=>'gz' },
);
