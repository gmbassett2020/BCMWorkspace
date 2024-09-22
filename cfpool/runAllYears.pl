#! /usr/bin/perl

use strict;
use warnings;

#my $uncertaintyOpt = "usePowerUncertainty=True";
my $uncertaintyOpt = "usePowerUncertainty=False";
my $label = "-noUncert";

my %maxWeek;
$maxWeek{1999} = 17;
$maxWeek{2000} = 17;
$maxWeek{2001} = 17;
$maxWeek{2002} = 18;
$maxWeek{2003} = 18;
$maxWeek{2004} = 17;
$maxWeek{2005} = 16;
$maxWeek{2006} = 16;
$maxWeek{2007} = 16;
$maxWeek{2008} = 17;
$maxWeek{2009} = 16;
$maxWeek{2010} = 16;
$maxWeek{2011} = 16;
$maxWeek{2012} = 16;
$maxWeek{2013} = 17;
$maxWeek{2014} = 19;
$maxWeek{2015} = 18;
$maxWeek{2016} = 17;
$maxWeek{2017} = 18;
$maxWeek{2018} = 18;
$maxWeek{2019} = 19;

foreach my $year (sort keys %maxWeek)
{
   for my $round (1..$maxWeek{$year})
   {
      my $roundString = sprintf("%0.2d", $round);
      my $runCommand = "python forecastAndRank.py currentSeason=$year maxRound=$round useTeamListFile=workspace/colI-list-1998_2019.csv useTeamSeasonsFile=workspace/colI-seasons-1998_2019.csv outputFile=workspace/cfpool/output/bcm_col_${year}_${roundString}${label}.txt $uncertaintyOpt";
      print "RUNNING: $runCommand\n";
      system "$runCommand";
   }
}

# python forecastAndRank.py currentSeason=1999 maxRound=5 useTeamListFile=workspace/colI-list-1998_2019.csv useTeamSeasonsFile=workspace/colI-seasons-1998_2019.csv outputFile=workspace/cfpool/tmp-bcm_col_1999_05.txt usePowerUncertainty=True |& tee tmp-bcm1999-05.txt

