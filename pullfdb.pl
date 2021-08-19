#pullfdb dumps forwarding database from snmp reachable device
#    output goes to ./fdb/%1.fdb
#  GBusby  Carondelet Health 11/4/2002

use strict;
use BER;
require 'SNMP_Session.pm';
my %descr;                    # table of port descriptions

my $host = $ARGV[0];          # hostname to walk
my $fdbfile;                  # file to dump fdb contents
my $community = $ARGV[1];     # community name
my $port = 161;               # standard snmp port
my $session;                  # SNMP session object
my $oid;                      # SNMP object id
my $oidFdbTable;              # oid for forwarding database
my $binding;                  # oid portion of snmp response
my $bindings;                 # snmp response bindings
my $ifindex;                  # interface index
my $poid;                     # pretty print version of oid
my $value;                    # value part of snmp response
my $mac;                      # mac address
my @smac;                     # mac address octet array
my $n;                        # foreach iteration variable

my $name;         # name assigned to host
my $mac;          # mac address of host
my @play;         # play with name field

if ($community eq "") {$community = "chprivate"}
if ($host eq "") {die "usage: pullfdb.pl <fdb source>\n"}
$fdbfile = $host . ".fdb";
open(FDB,">./fdb/$fdbfile") || die "could not open output $fdbfile\n";

@descr{0} = "self";
# possible kludge for Accelar
@descr{512} = "512";
# and for Passport 8600
@descr{4096} = "4096";

$session = SNMP_Session->open ($host, $community, $port)
    || die "couldn't open SNMP session to $host";

$oidFdbTable = encode_oid (1, 3, 6, 1, 2, 1, 17, 4, 3, 1, 2);
$oid =  encode_oid (1, 3, 6, 1, 2, 1, 17, 4, 3, 1, 2, 0, 0, 0, 0, 0, 1);
# $oid = $oidFdbTable;

  while (encoded_oid_prefix_p($oidFdbTable,$oid)) {
    $session->getnext_request_response ($oid);
    ($bindings) = $session->decode_get_response ($session->{pdu_buffer});

    	($binding,$bindings) = &decode_sequence ($bindings);
	($oid,$value) = &decode_by_template ($binding, "%O%@");
        $ifindex = &pretty_print ($value);
	if (encoded_oid_prefix_p($oidFdbTable,$oid)) {
           $poid = &pretty_print ($oid);
           $mac = extract_mac();
           print FDB portdescr($ifindex), "\t";
           print FDB "$mac\n"}
}

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

# extract_mac() pulls last 6 digits from $poid, formatted as mac address
sub extract_mac{
    @smac = split(/\./,$poid);
    @smac = splice(@smac,11,17);
    foreach $n (@smac) { $n = sprintf("%2.2x",$n);}
    return join("",@smac[0..5])
}