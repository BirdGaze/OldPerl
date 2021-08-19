#pullarp dumps arp table from snmp reachable device
#    GBusby  Carondelet Health  11/1/2002

use strict;
use BER;
require 'SNMP_Session.pm';

my %descr;                  # port description hash

my $host = $ARGV[0];        # host of arp table
my $arpfile;                # filename where arp table is to be stored
my $community = "chprivate";# default read community
my $port = 161;             # standard SNMP port
my $session;                # SNMP session variable
my $oid;                    # SNMP object id
my $oidArpTable;            # oid for forwarding database
my $binding;                # oid portion of snmp response
my $bindings;               # snmp response bindings
my $ifindex;                # interface index
my $poid;                   # pretty print version of oid
my $value;                  # SNMP value from get
my $mac;                    # mac address from arp
my $pip;                    # dotted decimal version of ip address
my @smac;                   # mac address bytes from snmp response

if ($host eq "") {die "usage: pullarp.pl <hostname>\n"}
$arpfile = $host . ".arp";
open (ARP,">./arp/$arpfile") || die "couldn't open $arpfile\n";

@descr{0} = "self";
# possible kludge for Accelar
@descr{512} = "512";

$session = SNMP_Session->open ($host, $community, $port)
    || die "couldn't open SNMP session to $host";

$oidArpTable = encode_oid (1, 3, 6, 1, 2, 1, 4, 22, 1, 2);
$oid = $oidArpTable;

  while (encoded_oid_prefix_p($oidArpTable,$oid)) {
    $session->getnext_request_response ($oid);
    ($bindings) = $session->decode_get_response ($session->{pdu_buffer});

    	($binding,$bindings) = &decode_sequence ($bindings);
	($oid,$value) = &decode_by_template ($binding, "%O%@");

	if (encoded_oid_prefix_p($oidArpTable,$oid)) {
           $poid = &pretty_print ($oid);
           $mac = &hex_string ($value);
           $pip = extract_ip();
           print ARP "$mac\t";
           print ARP "$pip\n"}
}
close ARP;
exit;

# portdescr(ifindex) returns port description for given interface index
#  inherits $session from context

sub portdescr {
    my $oidifDescr = encode_oid (1, 3, 6, 1, 2, 1, 2, 2, 1, 2, $ifindex);
    my $value = 0;
    my ($binding, $bindings, $oid);
 
    if (not defined @descr{$ifindex}) {
      @descr{$ifindex} = "$ifindex undef";
      if ($session->get_request_response ($oidifDescr)) {
         ($bindings) = $session->decode_get_response ($session->{pdu_buffer});
         ($binding,$bindings) = &decode_sequence ($bindings);
         ($oid,$value) = &decode_by_template ($binding, "%O%@");
       }
      if ($value) { @descr{$ifindex} = &pretty_print ($value)}
    }
    return @descr{$ifindex};
}

# extract_ip() pulls last 4 digits from $poid, formatted as ip address
sub extract_ip{
    @smac = split(/\./,$poid);
    return join(".",@smac[11..14])
}