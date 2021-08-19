# getwins.pl retrieves name <-> IP mappings from wins server
# GBusby Carondelet Health  11/4/2002

use strict;

my $preamble;     # first part of ipconfig line
my $address;      # second part of ipconfig line
my $winsserver;    # address of wins server from ipconfig
my $zone;         # subnet of zone from /EnumZones
my @zones;        # array of zones

my $ip;           # ip address leased
my $name;         # name assigned to host
my $type;         # wins record type
my @dumpline;     # fields from winsdmp
my @play;         # play with name field

# use ipconfig to get address of local wins server

open(IPCONFIG, "ipconfig/all |") || die "can't get ipconfig: $!";
    while(<IPCONFIG>) {
         ($preamble, $address) = split /\:/;
         if ($preamble =~/WINS Server/) { $winsserver = $address }
         }
close IPCONFIG;
chop($winsserver);
open(OUT,">./nam/WINS.nam");

# use winsdmp to dump name database from WINS server
     open(WINS, "winsdmp $winsserver |")
                    || die "can't do winsdmp: $!";
         while (<WINS>) {
              @dumpline = split /\,/;
              if ($dumpline[2] eq "20") {     # skip user names, etc
                  $name = $dumpline[1];
                  $ip = $dumpline[11];
                  chop($name);                # remove type byte
                  @play = split(/\s/,$name);  # remove jibble
                  $name = $play[0];
                  @play = split(/\"/,$name);
                  $name = $play[1];
                  print OUT "$ip\t";
                  print OUT "$name\n";
              }
        }
        close WINS || die "bad winsdmp: $! $?";
exit;
