#! /usr/bin/perl -w

# Create a cfpool database containing info on which games (week & teams) are used for each contest week

use strict;
use warnings;

use lib "/home/gbassett/googleDrive/Projects/bfm/perl";
use fbDivI;

$| = 1;         # autoflush stdout       

my $basedir = "/home/gbassett/googleDrive/Projects/bfm/col";
my $db_file = "$basedir/make_cfpool/cfpool_db_new.txt";

my %cfpool_db;
# $cfpool_db{$year}{$entry}{"$team1/$team2"}{week} = $week;
# $cfpool_db{$year}{$entry}{"$team1/$team2"}{winner} = 1; # 1-team1, 0-team2
# $entry - 2 digits, starting at 01
# $team1 & $team2 - full name with no trailing blanks
# $week - sched week number (start ai 1, no leading 0's)

foreach my $year (qw(2016 2017 2018 2019)) {

  print "::: working on year $year\n";

  # Read in game schedule

  my %sched;

#$sched{"$team1/$team2"}{$week}{winner} = 1; # 1-team1, 0-team2
# also set "$team2/$team1"
#$week - %0.2d

  my $sched_file = "$basedir/colI_$year";

  open SCHED, "<$sched_file" or die "ERROR opening sched file $sched_file ($!)";
  my $line = <SCHED>;
  my $week = 0;
  while (defined $line) {
    chomp $line;
    if ($line =~ /^\S/) {
      $week = sprintf "%0.2d", $week + 1;
#bdddddhssNCCbhhhhhhhhhhhhhhhhhhhhhhhbbssbCCbaaaaaaaaaaaaaa  -- inputflg = 1
# Se  1 00    Georgia Tech             00 PT Arizona
    } elsif ($line =~ /^\s(.{5}).(.\d)(.)..\s(\w.{23}).(.\d)\s..\s(\w.*)/) {
      my ($date,$score1,$home_flag,$team1,$score2,$team2) =
         ($1,$2,$3,$4,$5,$6);
      $team1 =~ s/\s+$//;
      $team2 =~ s/\s+$//;
      ($team1,$team2) = std_name_col($team1,$team2);
      if ($team1 && $team2) {
        if ($score1 > $score2) {
          $sched{"$team1/$team2"}{$week}{winner} = 1;
          $sched{"$team2/$team1"}{$week}{winner} = 0;
        } elsif ($score1 < $score2) {
          $sched{"$team1/$team2"}{$week}{winner} = 0;
          $sched{"$team2/$team1"}{$week}{winner} = 1;
        } else {
          $sched{"$team1/$team2"}{$week}{winner} = 0.5;
          $sched{"$team2/$team1"}{$week}{winner} = 0.5;
        }
      }
    } else {
      print "WARNING, could not parse: $line\n";
      die "FIXME";
    }
    $line = <SCHED>;
  }
  close SCHED;

  # Read in cfpool schedule & process each entry as it comes in

  my $cfpool_file = "$basedir/make_cfpool/cfpool_$year.txt";

  open CFPOOL, "<$cfpool_file" or die "ERROR opening cfpool file $cfpool_file ($!)";
  my @pool_in = <CFPOOL>;
  close CFPOOL;

  my $wk_cfpool = 0;

  foreach my $line (@pool_in) {
    if ($line =~ /CFPOOL/) {
print ":::-header $line";
      $wk_cfpool = sprintf "%0.2d", $wk_cfpool + 1;
    } elsif ($line =~ /^#/) {
      # skipping comment
    } elsif ($line =~ /^(.*?)\s+(at|vs)\s(.*?)\s*$/) {
      my ($team1p,$team2p) = ($1,$3);
      my ($team1,$team2) = std_name_col($team1p,$team2p);
      if ($team1 && $team2) {
        my $min_wk_diff;
        my $min_wk;
        my $team_str = "$team1/$team2";
        if (defined $sched{"$team_str"}) {
          foreach my $wk (sort keys %{$sched{"$team_str"}}) {
            if ($wk-$wk_cfpool >= 0 && (! (defined $min_wk_diff ) || abs($wk-$wk_cfpool-1) < $min_wk_diff)) {
              $min_wk_diff = abs($wk-$wk_cfpool-1);
              $min_wk = $wk+0;
            }
          }
        }
        if (defined $min_wk) {
          $cfpool_db{$year}{$wk_cfpool}{"$team_str"}{week} = $min_wk;
          $min_wk = sprintf "%0.2d", $min_wk;
          $cfpool_db{$year}{$wk_cfpool}{"$team_str"}{winner} = 
             $sched{"$team_str"}{$min_wk}{winner};
        } else {
print ":::-game $line";
          print "ERROR game not found: $team1/$team2\n";
          $cfpool_db{$year}{$wk_cfpool}{"$team_str"}{week} = "UNKNOWN";
        }
      } else {
print ":::-game $line";
        print "ERROR one or more teams not found: team1 $team1 team2 $team2\n";
      }
    } else {
       print "ERROR parsing pool line:\n   $line"  unless ($line =~ /^\s*$/);
    }
  }
}

open OUT, ">$db_file" or die "ERROR creating db file $db_file ($!)";

foreach my $year (sort keys %cfpool_db) {
  foreach my $week (sort keys %{$cfpool_db{$year}}) {
    foreach my $team_str (sort keys %{$cfpool_db{$year}{$week}}) {
      print OUT "$year:$week:$team_str:week=".
         $cfpool_db{$year}{$week}{"$team_str"}{week}.":winner=".
         $cfpool_db{$year}{$week}{"$team_str"}{winner}."\n";
    }
  }
  print OUT "\n";
}
close OUT or die "ERROR writing db file $db_file ($!)";
exit 0;

