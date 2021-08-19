# addarp.pl takes *.inv inventory file and adds ip addresses from arp dump
#  GBusby  Carondelet Health 11/4/2002

use strict;

my $prefix;       # first part of split
my $suffix;       # second part of split
my $port;         # port on switch where mac learned

my $num;          # DHCP lease number
my $mac;          # mac address of host
my $ip;           # ip address of host
my $fields;       # string of stored fields [port, ip, name]
my $xx;           # throwaway field from hash

my $invfile = $ARGV[0];  # inventory file source name
my $arpfile = $ARGV[1];  # arp dump file name

my $name;         # name of host
my $ipaddress;    # dotted decimal version of address
my %inv;          # inventory hash

if ($invfile eq "") {die "usage: addarp.pl <inventory source>  <arp source>\n"}
if ($arpfile eq "") {$arpfile = $invfile}
$invfile = $invfile . ".inv";
$arpfile = $arpfile . ".arp";

open(INV,"./inv/$invfile") || die "could not open $invfile\n";

# parse invfile into inv hash
while (<INV>){
 chomp;
 ($port, $mac, $ip, $name) = split/\t/;
 $inv{$mac} = "$port\t$ip\t$name";
 }
close (INV);

# find any matching mac's from arp

open(ARP,"./arp/$arpfile") || die "could not open $arpfile\n";

while (<ARP>){
 chomp;
 ($mac, $ip) = split /\t/;
 if ($inv{$mac}) {
     $fields = $inv{$mac};
     ($port, $xx, $name) = split(/\t/,$fields);
     $inv{$mac} = "$port\t$ip\t$name";
     }
  }
close (ARP);

# now dump inventory database back
open(INV,">./inv/$invfile");
foreach $mac (keys %inv) {
         $fields = $inv{$mac};
         ($port, $ip, $name) = split(/\t/,$fields);
         print INV "$port\t$mac\t$ip\t$name\n";
         }
close INV;
exit;