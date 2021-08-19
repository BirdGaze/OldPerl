# trimfdb.pl removes backbone table entries from fdb dump
#             based on port containing nexthop address
#  GBusby  3/2/2004

use strict;
use BER;
require 'SNMP_Session.pm';

my $prefix;       # first part of split
my $suffix;       # second part of split
my $port;         # port on switch where mac learned
my %descr;                  # port description hash

my $num;          # DHCP lease number
my $mac;          # mac address of host
my %gmac;         # mac addresses of gateway
my %gport;        # ports where gateway macs learned
my @play;         # play with name field

my $host         = $ARGV[0];   # host who fdb file we are trimming
my $fdbfile;      # fdb entries from pullfdb.pl
my $cleanfile;    # output without macs learned from backbone port
my $gateway;      # default gateway from mib-2.ip.iprouteTable

my $name;         # name of gateway
my $aliases;      # aliases of gateway
my $addrtype;     # ?? address type of gateway
my $length;       # length of addresses ??
my @addrs;        # IP addresses of gateway
my $address;      # IP address from @addrs
my $ipaddress;    # dotted decimal version of address
my $community = "chprivate";# default read community
my $snmport = 161;        # standard SNMP port
my $session;              # SNMP session variable
my $enoidgw;              # encoded oid for gateway interface
my $oidipRouteTable;      # oid for route table
my $binding;              # oid portion of snmp response
my $bindings;             # snmp response bindings
my $ifindex;              # interface index
my $oid;                  # generic oid
my $poid;                 # pretty print version of oid
my $value;                # SNMP value from get
my $gwport;               # port in path to gateway
my $mac;                  # mac address from arp

if ($host eq "") {die "usage: trimfdb.pl \<fdb source\> \n"}

$fdbfile = $host . ".fdb";
$cleanfile = $host . ".inv";

# find port of gateway

$session = SNMP_Session->open ($host, $community, $snmport)
    || die "couldn't open SNMP session to $host";

$oidipRouteTable = encode_oid (1, 3, 6, 1, 2, 1, 4, 21, 1, 2, 0, 0, 0, 0);

    $session->get_request_response ($oidipRouteTable);
    ($bindings) = $session->decode_get_response ($session->{pdu_buffer});

    ($binding,$bindings) = &decode_sequence ($bindings);
    ($oid,$value) = &decode_by_template ($binding, "%O%@");

	   $poid = &pretty_print ($oid);
           $gwport = &pretty_print ($value);


print "poid: $poid \nport: $gwport \nport description:",portdescr();


# filter out macs learned on gateway port

open(FDB,"./fdb/$fdbfile") || die "could not open $fdbfile\n";
open(CLEAN,">./inv/$cleanfile") || die "could not open $cleanfile\n";

while (<FDB>){
 chomp;
 ($port, $mac) = split /\t/;
 if ($gwport!=$port) {print CLEAN "$port\t$mac\n"} 
 }
close (FDB);

# portdescr(ifindex) returns port description for given interface index
#  inherits $session from context

sub portdescr {
    my $oidifDescr = encode_oid (1, 3, 6, 1, 2, 1, 2, 2, 1, 2, $gwport);
    my $value = 0;
    my ($binding, $bindings, $oid);
 
    @descr{$gwport} = "$gwport undef";
      if ($session->get_request_response ($oidifDescr)) {
         ($bindings) = $session->decode_get_response ($session->{pdu_buffer});
         ($binding,$bindings) = &decode_sequence ($bindings);
         ($oid,$value) = &decode_by_template ($binding, "%O%@");
       }
      if ($value) { @descr{$gwport} = &pretty_print ($value)}
    return @descr{$gwport};
}