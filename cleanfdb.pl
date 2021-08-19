# cleanfdb.pl removes backbone table entries from fdb dump
#             based on port containing default gateway
#  GBusby  10/31/2002

use strict;

my $prefix;       # first part of split
my $suffix;       # second part of split
my $port;         # port on switch where mac learned

my $num;          # DHCP lease number
my $mac;          # mac address of host
my %gmac;         # mac addresses of gateway
my %gport;        # ports where gateway macs learned
my @play;         # play with name field

my $fdbfile     = $ARGV[0];   # fdb entries from pullfdb.pl
my $cleanfile;    # output without macs learned from backbone port
my $gateway      = $ARGV[1];  # default gateway [from command line or ipconfig]

my $name;         # name of gateway
my $aliases;      # aliases of gateway
my $addrtype;     # ?? address type of gateway
my $length;       # length of addresses ??
my @addrs;        # IP addresses of gateway
my $address;      # IP address from @addrs
my $ipaddress;    # dotted decimal version of address

if ($fdbfile eq "") {die "usage: cleanfdb.pl \<fdb source\>  [gateway to exclude]\n"}
($prefix,$suffix) = split(/\./, $fdbfile);
$cleanfile = $prefix . ".inv";
if ($suffix eq "") {$fdbfile = $prefix . ".fdb"}

if ($gateway eq "") {
# use ipconfig to get address of default gateway

    open(IPCONFIG, "ipconfig |") || die "can't get ipconfig: $!";
       while(<IPCONFIG>) {
           chop;
           ($prefix, $suffix) = split /\:/;
           if ($prefix =~/Default Gateway/) { ($gateway = $suffix) =~ tr/[0-9.]//cd }
           }
    close IPCONFIG;
}
else {        # use gethostbyname to get IP addresses of gateway
     ($name,$aliases,$addrtype,$length,@addrs) = gethostbyname $gateway;
      }

foreach $address (@addrs) {
        $ipaddress = join(".",unpack("C*",$address));
        open(PING, "ping $ipaddress |") || die "can't ping: $!";
        close PING;
        open(ARP, "arp -a $ipaddress |") || die "can't arp: $!";
        while(<ARP>) {
              ($prefix, $suffix) = split;
               $suffix =~ tr/[0-9a-zA-Z]//cd;
       if ($prefix eq $ipaddress) {$gmac{$suffix} = $ipaddress; print "gw at: $prefix  $suffix\n"}
               }
       close ARP;
       }

# find port of gateway

open(FDB,"./fdb/$fdbfile") || die "could not open $fdbfile\n";

while (<FDB>){
 chomp;
 ($port, $mac) = split /\t/;
 if ($gmac{$mac}) {$gport{$port} = $mac; print "gw on: $port  $mac\n"} 
 }
close (FDB);

# filter out macs learned on backbone port (toward gateway)

open(FDB,"./fdb/$fdbfile") || die "could not open $fdbfile\n";
open(CLEAN,">./inv/$cleanfile") || die "could not open $cleanfile\n";

while (<FDB>){
 chomp;
 ($port, $mac) = split /\t/;
 if (!$gport{$port}) {print CLEAN "$port\t$mac\n"} 
 }
close (FDB);