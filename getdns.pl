# getdns.pl retrieves name <-> IP mappings from DNS server
# GBusby Carondelet Health 11/4/2002

use strict;

my $preamble;     # first part of ipconfig line
my $address;      # second part of ipconfig line
my $dnsserver;    # address of dns server from ipconfig
my $zone;         # subnet of zone from /EnumZones
my @zones;        # array of zones

my $time;         # DNS record lifetime
my $ip;           # ip address leased
my $name;         # name assigned to host
my $type;         # DNS record type
my @play;         # play with name field

# use ipconfig to get address of local dns server

open(IPCONFIG, "ipconfig/all |") || die "can't get ipconfig: $!";
    while(<IPCONFIG>) {
         ($preamble, $address) = split /\:/;
         if ($preamble =~/DNS Server/) { $dnsserver = $address }
         }
close IPCONFIG;
chop($dnsserver);

# use dnscmd to get zones in use

open(DNS, "dnscmd $dnsserver /EnumZones |") || die "can't get zones: $!";
     while(<DNS>) {
          ($zone) = split;    # split on whitespace
           if ($zone =~ /^[a-z]+\./) {push @zones, $zone}  # only if begins with alpha
          }
open(OUT,">./nam/DNS.nam");

# use dnscmd to dump client database from dns server
foreach $zone (@zones) {
     open(DNS, "dnscmd $dnsserver /EnumRecords $zone \"\@\" |")
                    || die "can't do dnscmd: $!";
         while (<DNS>) {
              ($name, $time, $type, $ip) = split;
              if ($type eq "A") {              # skip CNAME, etc
                  @play = split(/\./,$name);  # skip domain suffixes
                  $name = $play[0];
                  print OUT "$ip\t";
                  print OUT "$name\n";
              }
        }
        close DNS || die "bad dnscmd: $! $?";
    }
exit;
