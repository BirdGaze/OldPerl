#fwlist.pl produces firmware list - basically sysdescr from snmp reachable devices
use BER;
require 'SNMP_Session.pm';

# Set $host to the name of the host whose SNMP agent you want
# to talk to.  Set $community to the community name under
# which you want to talk to the agent.	Set port to the UDP
# port on which the agent listens (usually 161).
if($#ARGV < 1) {
die "usage: xfwlist.pl <list of hosts> <output file>\n"
}

$hostlist = $ARGV[0];
$output = $ARGV[1];

if ($output eq "") { $output = ">-";}
open(OUT,">$output");

$community = "public";
$port = 161;
$oidSysDescr = encode_oid (1, 3, 6, 1, 2, 1, 1, 1, 0);

open(HOSTS,$hostlist);
while(<HOSTS>) {
 chomp;
 ($host) = split /\t/;
# $host = $_;
 $session = SNMP_Session->open ($host, $community, $port)
     || die "couldn't open SNMP session to $host";

 if ($session->get_request_response ($oidSysDescr)) {
     ($bindings) = $session->decode_get_response ($session->{pdu_buffer});

     while ($bindings ne '') {
 	($binding,$bindings) = &decode_sequence ($bindings);
 	($oid,$value) = &decode_by_template ($binding, "%O%@");
 	print OUT "$host ", &pretty_print ($value), "\n";
     }
 } else {
     print OUT "$host: No response from agent\n";
 }
}