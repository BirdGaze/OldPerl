#xfdb dumps forwarding database from snmp reachable device
use BER;
require 'SNMP_Session.pm';

# Set $host to the name of the host whose SNMP agent you want
# to talk to.  Set $community to the community name under
# which you want to talk to the agent.	Set port to the UDP
# port on which the agent listens (usually 161).
if($#ARGV < 1) {
die "usage: xfdb.pl <host ip>\n"
}

$host = $ARGV[0];
$community = "public";
$port = 161;

$session = SNMP_Session->open ($host, $community, $port)
    || die "couldn't open SNMP session to $host";

$oidFdbTable = encode_oid (1, 3, 6, 1, 2, 1, 17, 4, 3, 1, 2);
$oid = $oidFdbTable;
$oidFdbMark = &pretty_print($oidFdbTable);
$oidPretty = &pretty_print($oid);

while (index($oidPretty, $oidFdbMark) == 0) {
    $session->getnext_request_response ($oid);
    ($bindings) = $session->decode_get_response ($session->{pdu_buffer});

    	($binding,$bindings) = &decode_sequence ($bindings);
	($oid,$value) = &decode_by_template ($binding, "%O%@");
        $ifindex = &pretty_print ($value);
        $oidPretty = &pretty_print($oid);
	if (index($oidPretty, $oidFdbMark) ==0) {
           print &pretty_print ($oid)," => ", portdescr($ifindex), "\n"}
}
print "        oid: ",&pretty_print($oid),"\n";
print "index   oid: ",index($oid,$oidFdbTable),"\n";
print "oidFdbTable: ", &pretty_print($oidFdbTable), "\n";

# portdescr(ifindex) returns port description for given interface index
#  inherits $session from context

sub portdescr {
    my $oidifDescr = encode_oid (1, 3, 6, 1, 2, 1, 2, 2, 1, 2, $ifindex);
    my $value = 0;
    my ($binding, $bindings, $oid);
# possible kludge for Accelar
    if ($ifindex eq "512") {return "undef"};
    if ($ifindex eq "0") {return "self"};

    if ($session->get_request_response ($oidifDescr)) {
    ($bindings) = $session->decode_get_response ($session->{pdu_buffer});

    ($binding,$bindings) = &decode_sequence ($bindings);
    ($oid,$value) = &decode_by_template ($binding, "%O%@");
     }
     if ($value) { return &pretty_print ($value)}
     else { return "$ifindex undef"}
}
