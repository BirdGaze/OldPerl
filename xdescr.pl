use BER;
require 'SNMP_Session.pm';

# Set $host to the name of the host whose SNMP agent you want
# to talk to.  Set $community to the community name under
# which you want to talk to the agent.	Set port to the UDP
# port on which the agent listens (usually 161).
if($#ARGV < 1) {
die "usage: xdescr.pl <host ip>\n"
}

$host = $ARGV[0];
$community = "public";
$port = 161;

$session = SNMP_Session->open ($host, $community, $port)
    || die "couldn't open SNMP session to $host";

$oidSysDescr = encode_oid (1, 3, 6, 1, 2, 1, 1, 1, 0);

if ($session->get_request_response ($oidSysDescr)) {
    ($bindings) = $session->decode_get_response ($session->{pdu_buffer});

    while ($bindings ne '') {
	($binding,$bindings) = &decode_sequence ($bindings);
	($oid,$value) = &decode_by_template ($binding, "%O%@");
	print &pretty_print ($oid)," => ", &pretty_print ($value), "\n";
    }
} else {
    die "No response from agent on $host";
}
