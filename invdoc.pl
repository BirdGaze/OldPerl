# INVDOC.PL - formats autoinventory file into word document
# usage: invdoc.pl <inventory source>
#    eg: invdoc.pl jxlr
# action: fetches inventory file as ./inv/<source>.inv 
#         produces ./doc/<source>.doc
#         document is tabular with appropriate headings
#

use strict;
use Win32::OLE;

my $path = Win32::GetCwd();
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

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$mon +=1;
$year +=1900;
my $date = "$mon/$mday/$year";
if($filearg eq "")       
    {
     die "usage: invdoc.pl <inventory source>\n";  
     }
my $invfile = "$filearg.inv";

my $word = Win32::OLE->new('Word.Application','Quit') or die "no word app\n";
my $doc = $word->Documents->Open($invpath.$invfile) or die "no doc open $invfile\n";
my $selection = $word->Selection;
$selection->WholeStory();
my $table = $selection->ConvertToTable("\t");

$selection->InsertRowsAbove(1);
$table->Cell(1,1)->Range->InsertAfter("port");
$table->Cell(1,2)->Range->InsertAfter("mac");
$table->Cell(1,3)->Range->InsertAfter("ip");
$table->Cell(1,4)->Range->InsertAfter("name");

my $section = $doc->Sections(1);
my $header = $section->Headers(1);
$header->Range->Font->{'Size'} = 24;
$header->Range->{'Text'} = "$filearg port inventory $date";
$doc->SaveAs($docpath.$docfile,0);  # save in word document format

exit;

