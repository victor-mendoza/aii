use strict;
use warnings;
use Test::More;
use Test::Quattor qw(pxelinux_ks_nologging_host);
use NCM::Component::pxelinux;
use CAF::FileWriter;
use CAF::Object;

=pod

=head1 SYNOPSIS

Tests for the C<pxeprint> method.

=cut

$CAF::Object::NoAction = 1;

# mock filepath, it has this_app->option
my $fp = "target/test/pxelinux";
my $mockpxe = Test::MockModule->new('NCM::Component::pxelinux');
$mockpxe->mock('filepath', $fp);

my $ks = NCM::Component::pxelinux->new('pxelinux_ks');
my $cfg = get_config_for_profile('pxelinux_ks_nologging_host');

NCM::Component::pxelinux::pxeprint($cfg);

my $fh = get_file($fp);

unlike($fh, qr{\ssyslog}, 'no syslog config');
unlike($fh, qr{\sloglevel}, 'no loglevel config');


done_testing();
