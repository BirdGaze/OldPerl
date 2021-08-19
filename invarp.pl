# invarp.pl takes *.arp file (e.g. from router) and turns it into an inv
#  GBusby  Carondelet Health 1/6/2006

use strict;

my $prefix;       # first part of split
my $suffix;       # second part of split
my $port;         # port on switch where mac learned

my $num;          # DHCP lease number
my $mac;          # mac address of host
my $ip;           # ip address of host
my $fields;       # string of stored fields [port, ip, name]
my $xx;           # throwaway field from hash

my $arpfile = $ARGV[0];  # arp dump file name
my $invfile;

my $name;         # name of host
my $ipaddress;    # dotted decimal version of address
my %inv;          # inventory hash

if ($arpfile eq "") {die "usage: invarp.pl <arp source>\n"}
$invfile = $arpfile;
$invfile = $invfile . ".inv";
$arpfile = $arpfile . ".arp";

open(ARP,"./arp/$arpfile") || die "could not open $arpfile\n";
open(INV,">./inv/$invfile");
while (<ARP>){
 chomp;
 ($mac, $ip) = split /\t/;
 print INV "$port\t$mac\t$ip\t$name\n";
         }
close INV;
close ARP;
exit;