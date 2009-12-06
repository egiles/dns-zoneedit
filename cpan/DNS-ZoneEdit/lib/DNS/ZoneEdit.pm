package DNS::ZoneEdit;

use warnings;
use strict;
use Carp;
use LWP::UserAgent;
use CGI::Util qw(escape);
use HTTP::Request::Common qw(GET);

use base qw(LWP::UserAgent);

use constant URL => 'dynamic.zoneedit.com/auth/dynamic.html';

our $VERSION = 0.01;

=head1 NAME

DNS::ZoneEdit - Update your ZoneEdit dynamic DNS entries

=head1 SYNOPSIS

This module allows you to update your ZoneEdit ( http://www.zoneedit.com/ )
dynamic DNS records. This is done via an http get using the L<libwww-perl>
modules.

 	use DNS::ZoneEdit;

	my $ze = DNS::ZoneEdit->new;
	$ze->update( username => "foo", password => "bar" ) || die "Failed: $@";

=head1 METHODS

=over 4

=cut

=item DNS::ZoneEdit->new();

Create a new ZoneEdit object. This is actually an inheritted L<LWP::UserAgent>
so you may like to use some of the UserAgent methods. For example,
if you are behind a proxy server:

	$ze->proxy('http', 'http://proxy.sn.no:8001/');

=cut

sub new {
	my ($pack,@args) = @_;
	my $obj = $pack->SUPER::new(@args);
	$obj->agent("DNS::ZoneEdit perl module");
	return $obj;
}


sub _can_do_https {
	eval "use Crypt::SSLeay";

	if ($@) {
		return;
	} else {
		return 1;
	}
}


=item $ze->update(%args);

Updates your ZoneEdit dynamic DNS records. Valid C<%args> are:

=over 8

C<username> - Your ZoneEdit login name. This is required.

C<password> - The corresponding password. This is required.

C<hostname> - The full host being updated. This is required.
Contains a comma-delimited list of hosts that have IP addresses. This parameter
may be *.domain.com to update a wildcard A-record.

C<myip> - The IP address of the client to be updated.  This
defaults to the IP address of the incoming connection (handy if you are
being natted).

C<secure> - Values are either C<1> or C<0>. If C<1>, then SSL https is used to connect
to ZoneEdit. The SSL connection has the big advantage
that your passwords are not passed in plain-text accross the internet. Secure is on by
default if Crypt::SSLeay is installed. A warning will be generated if it's not
installed, unless you set C<secure => 0>. If you set C<secure => 1> and the module is
unavailable, the module will C<croak>.

=back

The function returns C<TRUE> of success. On failure it returns C<FALSE> and 
sets C<$@>.

=cut

sub update {
	my ($obj,%args) = @_;

	my %get;
	while (my ($k,$v) = each %args) {
		if    ( $k eq "username" ) { $obj->{"username"} = $v }
		elsif ( $k eq "password" ) { $obj->{"password"} = $v }
		elsif ( $k eq "hostname" ) { $get{host} = $v         }
		elsif ( $k eq "myip"     ) { $get{dnsto} = $v        }
		elsif ( $k eq "secure"   ) { $obj->{"secure"} = $v   }
		else { carp "update(): Bad argument $k" }
	}

	croak "update(): Argument 'username' is required" 
		unless defined $obj->{"username"};

	croak "update(): Argument 'password' is required" 
		unless defined $obj->{"password"};

	croak "update(): Argument 'hostname' is required" 
		unless defined $args{"hostname"};

	if (defined $obj->{"secure"}) {
		if ($obj->{"secure"} && ! _can_do_https()) {
			croak "Can't run in secure mode - try installing Crypt::SSLeay"
		}
	} else {
		if (_can_do_https()) {
			$obj->{"secure"} = 1;
		} else {
			carp "** USING INSECURE MODE - PLEASE READ THE DOCUMENTATION **\n";
			$obj->{"secure"} = 0;
		}
	}

	## Make the GET request URL.

	my $proto = $obj->{"secure"} ? "https://" : "http://";

	my $qry = join('&', map { escape($_)."=".escape($get{$_}) } keys %get);

	my $resp = $obj->request(GET $proto.URL."?".$qry);

	if ($resp->is_success) {
		chomp(my $content = $resp->content);
		if ( $content =~ m/CODE="2\d+"/ ) {
			return 1;
		} else {
			$@ = 'ZoneEdit said "'.$content.'"';
			return;
		}
	} else {
		$@ = 'HTTP request failed "'.$resp->status_line.'"';
		return;
	}
}

=item DNS::ZoneEdit->get_basic_credentials();

Since ZoneEdit object is an inheritted L<LWP::UserAgent>, it overrides
this UserAgent method for your convenience. It uses the credentials passed
in the constructor. There is no real reason to override, or call this.

	sub get_basic_credentials { ($_[0]->{"username"}, $_[0]->{"password"}) }

=cut

sub get_basic_credentials { ($_[0]->{"username"}, $_[0]->{"password"}) }

=back

=head1 NOTES

There are some example scripts in the C<examples> directory of the module
distribution. These are designed to run out of cron (or similar). You
should not run them to often to avoid overloading the ZoneEdit servers. Ideally
your code should cache the existing value for your IP, and only update
ZoneEdit when it changes.

=head1 ACKNOWLEDGEMENTS

It is actually based on Gavin Brock's excellent DNS::EasyDNS.

For more information about the ZoneEdit services please visit 
http://www.zoneedit.com/. This module is not written nor supported by 
ZoneEdit LLC.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Evan Giles, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=head1 SEE ALSO

L<LWP::UserAgent> L<DNS::EasyDNS>

=cut

1; # End of DNS::ZoneEdit
