use strict;
use warnings;

use Test::More tests => 7;

#==============================================================================#

BEGIN { use_ok('DNS::ZoneEdit') };

my $ze = DNS::ZoneEdit->new();

my $params;

$params = $ze->_make_request_url(hostname=>"hostvalue",myip=>"address");
like($params,qr/host=/,"hostname in param query");
like($params,qr/hostvalue/,"hostname paramvalue in query");
like($params,qr/dnsto=/,"myip param in query");
like($params,qr/address/,"myip paramvalue in query");

if ( $ze->_can_do_https() ) {
    $params = $ze->_make_request_url(secure=>1);
    like($params,qr/https:/,"secure query");
} else {
    ok(1,"Assuming we COULD do SSL if you had the right packages installed");
}

$params = $ze->_make_request_url(secure=>0);
like($params,qr/http:/,"insecure query");
#==============================================================================#
