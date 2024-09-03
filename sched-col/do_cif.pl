#! /usr/bin/perl
use warnings;
use strict;
#my $year = "2014";
#my $type = "colI";
my $year = 2017;

for (my $month=9; $month<=12; $month+=1)
{
    for (my $day=1; $day<=31; $day+=1)
    {
        my $dateStr = (sprintf "%04d%02d%02d", $year, $month, $day);
        print `lynx -width=500 -dump "http://www.maxpreps.com/list/schedules_scores.aspx?date=$month/$day/$year&gendersport=boys,football&state=ca" > cif_scores_$dateStr.txt`;
    }
}
