# INVDOC.PL - formats autoinventory file into rtf document
# usage: invdoc.pl <inventory source>
#    eg: invdoc.pl jxlr
# action: fetches inventory file as ./inv/<source>.inv 
#         produces ./doc/<source>.doc
#         document is tabular with appropriate headings
#

use strict;
use Cwd;

my $path = cwd();
my $filearg  = $ARGV[0];
my $invpath = $path."\\inv\\";
my $docpath = $path."\\doc\\";
my $docfile = "$filearg.doc";
my $sec;
my $min;
my $hour;
my $mday;
my $mon;
my $year;
my $wday;
my $yday;
my $isdst;
my $port;
my $mac;
my $ip;
my $name;
print $path;
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$mon +=1;
$year +=1900;
my $date = "$mon/$mday/$year";
if($filearg eq "")       
    {
     die "usage: invdoc.pl <inventory source>\n";  
     }
my $invfile = "$filearg.inv";
my $rtffile = "$filearg.rtf";

open(INV,"$invpath$invfile") || die "could not open $invpath$invfile\n";
open(RTF,">$docpath$rtffile") || die "could not open $docpath$rtffile\n";

print RTF "{\\rtf1\\ansi\\ansicpg1252\\deff0\\deflang1033{\\fonttbl{\\f0\\fswiss\\fcharset0 Arial;}}\n";
print RTF "{\\header {\\fs48 $filearg port inventory $date}}\n";

my $rowdef = "\\intbl \\trowd\\trgraph100\\trleft0\\cellx2500\\cellx5000\\cellx7000\\cellx9500";

print RTF "$rowdef\n\\intbl {port \\cell mac \\cell ip \\cell name \\cell\\row }\n";

while (<INV>) {
   chomp;
   ($port, $mac, $ip, $name) = split/\t/;
   print RTF "$rowdef\n\\pard \\intbl {$port \\cell $mac \\cell $ip \\cell $name \\cell\\row }\n";
   }
print RTF "}\n";
close RTF;
close INV;

exit;

