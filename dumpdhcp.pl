# dumpdhcp.pl retrieves client lease information from DHCP server and dumps to sysout

use strict;

my $preamble;     # first part of ipconfig line
my $address;      # second part of ipconfig line
my $dhcpserver;   # address of dhcp server from ipconfig
my $winsserver;   # backup server address - guess WINS and DHCP same server
my $scope;        # subnet of scope from MibCounts
my @scopes;       # array of subnet addresses

my $num;          # DHCP lease number
my $ip;           # ip address leased
my $name;         # name assigned to host
my $mac;          # mac address of host
my @play;         # play with name field

# get address of dhcp server


$dhcpserver = $ARGV[0];

# use dhcpcmd to get scopes in use

open(DHCP, "dhcpcmd $dhcpserver MibCounts |") || die "can't get scopes: $!";
     while(<DHCP>) {
          ($preamble, $scope) = split /\=/;
           if ($preamble =~/Subnet/) {push @scopes, $scope}
          }

# use dhcpcmd to dump client database from dhcp server
foreach $scope (@scopes) {
     $scope = substr($scope,0,-2);
     open(DHCP, "dhcpcmd $dhcpserver EnumClients $scope -h |")
                    || die "can't do dhcpcmd: $!";
         while (<DHCP>) {
              ($num, $ip, $name, $mac) = split;
              if ($num =~/\d/) {              # skip comments from dhcpcmd
                  @play = split(/\./,$name);  # skip domain suffixes
                  $name = $play[0];
                  print "$mac\t$ip\t$name\n";
              }
        }
        close DHCP || die "bad dhcpcmd: $! $?";
    }
exit;
