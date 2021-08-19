# addname.pl takes *.inv inventory file and adds device names from .nam file
#                        source may have been DHCP, WINS, or DNS
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
my $namfile = $ARGV[1];  # nam dump file name

my $name;         # name of host
my $ipaddress;    # dotted decimal version of address
my %inv;          # inventory hash

if ($invfile eq "") {die "usage: addnam.pl <inventory source>  <nam source>\n"}
if ($namfile eq "") {$namfile = $invfile}
$invfile = $invfile . ".inv";
$namfile = $namfile . ".nam";

open(INV,"./inv/$invfile") || die "could not open $invfile\n";

# parse invfile into inv hash
while (<INV>){
 chomp;
 ($port, $mac, $ip, $name) = split/\t/;
 $inv{$ip} = "$port\t$mac\t$name";
 }
close (INV);

# find any matching mac's from name file

open(NAM,"./nam/$namfile") || die "could not open $namfile\n";

while (<NAM>){
 chomp;
 ($ip, $name) = split /\t/;
 if ($inv{$ip}) {
     $fields = $inv{$ip};
     ($port, $mac, $xx) = split(/\t/,$fields);
     $inv{$ip} = "$port\t$mac\t$name";
     }
  }
close (NAM);

# now dump inventory database back
open(INV,">./inv/$invfile");
foreach $ip (keys %inv) {
         $fields = $inv{$ip};
         ($port, $mac, $name) = split(/\t/,$fields);
         print INV "$port\t$mac\t$ip\t$name\n";
         }
close INV;
exit;