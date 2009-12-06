use strict;
use warnings;

use Test::More tests => 6;

#==============================================================================#

BEGIN { use_ok('DNS::ZoneEdit') };

my $ze = DNS::ZoneEdit->new();

ok(ref($ze) eq "DNS::ZoneEdit", "Object has correct type");

ok($ze->isa("LWP::UserAgent"), "Object inheritance ok");

ok($ze->can("update"), "Object has update method");

ok(!$ze->update(
	username => 'test',
	password => 'bogus',
	hostname => 'bogus',
), "Check a bogus request");

ok($@ =~ /^HTTP request failed /, "HTTP Error looks correct");

#==============================================================================#