#! /usr/bin/perl -w

use lib "../";
use fbDivI;

# count the number of games listed for each team in the season

my $sched_file = shift @ARGV;
my $list_file = shift @ARGV;
my $year = shift @ARGV;

die "Usage: $ARGV[0] <sched_file> <list_file> <year>" unless ($sched_file && $list_file);

open SCHED, "$sched_file" or die "ERROR opening schedule file, $sched_file ($!)";
my @sched = <SCHED>;
close SCHED or die "ERROR reading schedule file, $sched_file ($!)";

# strip off header
shift @sched;

my %game_cnt;
foreach my $game (@sched) {
   chomp ($game);
   my ($season, $roundNumber, $roundName, $date_str, $homeFlag, $score1, $team1, $score2, $team2) = split /,/, $game;
   chomp($team2);
   if ($season eq $year)
   {
      $game_cnt{"$team1"} += 1;
      $game_cnt{"$team2"} += 1;
      #print "::: sched team1 $team2 team2 $team2\n";
   }
}

open LIST, "$list_file" or die "ERROR opening list file, $list_file ($!)";
my @list = <LIST>;
close LIST or die "ERROR reading list file, $list_file ($!)";

# strip off header
shift @list;

foreach my $teamListing (@list)
{
   my ($team,$season,$division,$conference) = split /,/, $teamListing;

   if ($season == $year)
   {
      $game_cnt{"$team"} ||= 0;
      printf "%-24.24s %d\n", $team, $game_cnt{"$team"};
   }
}
