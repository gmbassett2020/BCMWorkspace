#! /usr/bin/perl
use warnings;

#my $year = "2014";
#my $type = "colI";

print `lynx -width=500 -dump http://prwolfe.bol.ucla.edu/cfootball/scores.htm > tmp_scores`;

print `lynx -width=500 -dump http://prwolfe.bol.ucla.edu/cfootball/schedules.htm > tmp_sched_raw`;


print `./convsched01.pl < tmp_sched_raw | sort > tmp_sched`
