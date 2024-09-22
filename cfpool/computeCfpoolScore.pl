#! /usr/bin/perl -w

use lib "../";
use fbDivI;

use strict;

$! = 1; # OUTPUT AUTOFLUSH

my $cfpool_db_file = "cfpool_db.txt";
#my $cfpool_db_file = "cfpool_db-testing.txt";

#my $predFile = "predBfm1999-2019.txt";
#my $predFile = "predBcm1999-2019.txt";
#my $predFile = "predBfm1999.txt";
#my $predFile = "predBcm1999.txt";
#my $predFile = "predBcmNoUncert1999.txt";
my $predFile = "predBcmNoUncert1999-2019.txt";

# Read in CFPOOL data
my %cfpool_db;
#      print OUT "$year:$entry:$team_str\t\t:week=".
#         $cfpool_db{$year}{$entry}{"$team_str"}{week}.":winner=".
#         $cfpool_db{$year}{$entry}{"$team_str"}{winner}."\n";
my @db_in;
if ($cfpool_db_file) {
   open DB, "<$cfpool_db_file" 
      or die "ERROR opening CFPOOL file $cfpool_db_file ($!)";
   @db_in = <DB>;
   close DB;
}
foreach my $line (@db_in) {
   chomp $line;
#print "::: db: $line\n";
   if ($line =~ /^(\d{4}):(.*):(.*?):\s*week=(.*):winner=(\d)/) {
      my ($year,$entry,$team_str,$week,$winner) = ($1,$2,$3,$4,$5);
#print "::: year $year entry $entry team_str $team_str week $week winner $winner\n";
      $cfpool_db{$year}{$entry}{$team_str}{week} = $week;
      $cfpool_db{$year}{$entry}{$team_str}{winner} = $winner;
      if ($team_str =~ m|^(.*)/(.*)|) {
         my $team_str2 = "$2/$1";
         $cfpool_db{$year}{$entry}{$team_str2}{week} = $week;
         $cfpool_db{$year}{$entry}{$team_str2}{winner} = 1-$winner;
      } else {
         print "ERROR parsing cfpool team string $team_str ($line)\n";
      }
   }
}

my @predictions = `cat $predFile`;
# Fill in %pred_scores
#$pred_scores{$year}{$week}{$team_str};
my %pred_scores;

my %years;
# Parse raw preds and put in %pred_scores;

foreach my $prediction (@predictions)
{
   chomp($prediction);
   my ($year, $week, $prob, $team1, $predScore1, $team2, $predScore2, $spread);
   #if ($prediction =~ /.*(\d{4})_(\d{2}).out:result:\s*(\d+)%\s*\d+\s+(.*?)\s+\d+\s+(\S+),\s+\d+\s+(.*?)\s+\d+\s+(.*)/)
   if ($prediction =~ /.*(\d{4})_(\d{2}).out:pred2:\s*(\d+)%\s*(\S+)\s+\d+\s+(.*?)\s+\S+,\s+\d+\s+(.*?)\s+\S+$/)
   {
      #($year, $week, $prob, $team1, $predScore1, $team2, $predScore2) = ($1, $2, $3, $4, $5, $6, $7);
      ($year, $week, $prob, $spread, $team1, $team2) = ($1, $2, $3, $4, $5, $6);
      #print "::: pred entry yr=$year wk=$week prob=$prob team1=$team1 predScore1=$predScore1 team2 $team2 predScore2 $predScore2\n";
      ($team1, $team2) = std_name_col($team1,$team2);
      #my $spread = $predScore1-$predScore2;
      # add an indication of spread to be proxy for more precision on the forecast probability
      #if ($spread > 0)
      #{
      #   # assuming max spread of 100, this will give a number between 0 and less than 10
      #   my $newProb = $prob + sqrt($spread); 
      #   print ":::-1 oldProb=$prob newProb=$newProb spread=spread\n";
      #   $prob = $newProb;
      #}
      #elsif ($spread < 0)
      #{
      #   # assuming max spread of 100, this will give a number between 0 and less than 10
      #   my $newProb = $prob - sqrt(-$spread); 
      #   print ":::-1 oldProb=$prob newProb=$newProb spread=spread\n";
      #   $prob = $newProb;
      #}
      if ($prob >= 50)
      {
         $pred_scores{$year}{$week}{"$team1/$team2"} = sprintf("%0.2d%0.3d %s/%s", $prob, $spread*10+30, $team1, $team2);
         #print ":::-1 pred_scores{$year}{$week}{$team1/$team2} = ".$pred_scores{$year}{$week}{"$team1/$team2"}."\n";
      }
      else
      {
         $pred_scores{$year}{$week}{"$team2/$team1"} = sprintf("%0.2d%0.3d %s/%s", 100-$prob, -$spread*10+30, $team2, $team1);
         #print ":::-2 pred_scores{$year}{$week}{$team2/$team1} = ".$pred_scores{$year}{$week}{"$team2/$team1"}."\n";
      }
      $years{$year} += 1;
   }
   elsif ($prediction =~ /.*(\d{4})_(\d{2})(-\S+|).txt:.* prob=(\S+)\s+(.*?)--(.*?)\s+predicted.*/)
   {
      ($year, $week, $prob, $team1, $team2) = ($1, $2, $4, $5, $6);
      ($team1, $team2) = std_name_col($team1,$team2);
      $pred_scores{$year}{$week}{"$team1/$team2"} = sprintf("%0.5d %s/%s", 100000*$prob, $team1, $team2);
      #print "::: pred entry yr=$year wk=$week prob=$prob team1=$team1 team2 $team2 predString ".$pred_scores{$year}{$week}{"$team1/$team2"}."\n";
      $years{$year} += 1;
   }
   else
   {
      die "ERROR parsing prediction $prediction";
   }
}

# Compute CFPOOL score

my $cfpool_score = 0;
my $cfpool_perfect = 0;
my %cfpoolScoreByEntryNumber;

foreach my $year (sort keys %years)
{

   my $entry_score;
   foreach my $entry (sort keys %{$cfpool_db{$year}}) {
      print "::: cfpool $year entry $entry\n";
      my $tot_raw = 0;
      my $raw = 1;
      my %entry;
      my $num_entries = 0;
      $entry_score = 0;
      foreach my $team_str (keys %{$cfpool_db{$year}{$entry}}) {
         # remember since $team1/$team2 AND $team2/$team1 are both in 
         # in the database, it is not necessary to reverse team_str
         my $week = sprintf "%0.2d",
            $cfpool_db{$year}{$entry}{"$team_str"}{week};
         #print "::: cfpool year $year entry $entry team_str $team_str week $week\n";
         if (exists $pred_scores{$year}{$week}{$team_str}) {
            $num_entries += 1;
            $tot_raw += $raw;
            $raw *= 1.1;
            my $prob_sort_str = $pred_scores{$year}{$week}{$team_str};
            $entry{$prob_sort_str} = $cfpool_db{$year}{$entry}{$team_str}{winner};
            print "::: year $year entry $entry team_str $team_str prob_sort_str $prob_sort_str winner $entry{$prob_sort_str}\n";
         }
      }
      if ($num_entries > 0)
      {
         my $score_val = ($tot_raw) ? 1000/$tot_raw : 0;
         print "::: score_val $score_val tot_raw $tot_raw\n";
         foreach my $prob_sort_str (sort keys %entry) {
            $entry_score += $entry{"$prob_sort_str"} * $score_val;
            print ":::   str $prob_sort_str correct $entry{$prob_sort_str} val $score_val\n";
            $score_val *= 1.1;
         }
         if ($cfpool_db_file) {
            print "cfpool year $year entry $entry score $entry_score\n";
            $cfpool_score += $entry_score; # add this entry's score to total score
            $cfpoolScoreByEntryNumber{$entry}{cfpoolScore} += $entry_score;
            $cfpool_perfect += 1000 if ($entry_score);
            $cfpoolScoreByEntryNumber{$entry}{cfpoolCount} += 1;
            if ($num_entries >= 20) # bowl entries count double
            {
               $cfpool_score += $entry_score; # add this entry's score to total score
               $cfpoolScoreByEntryNumber{$entry}{cfpoolScore} += $entry_score;
               $cfpool_perfect += 1000 if ($entry_score);
               $cfpoolScoreByEntryNumber{$entry}{cfpoolCount} += 1;
            }
         }
         else
         {
            $cfpool_score += 0;
         }
      }
   }
}

my $cfpoolAveScore = 1000*$cfpool_score/$cfpool_perfect;
print "Average score: $cfpoolAveScore\n";
foreach my $entry (sort keys %cfpoolScoreByEntryNumber)
{
   $cfpoolScoreByEntryNumber{$entry}{cfpoolAveScore} = $cfpoolScoreByEntryNumber{$entry}{cfpoolScore} / $cfpoolScoreByEntryNumber{$entry}{cfpoolCount};
   
   print "   Entry $entry aveScore: $cfpoolScoreByEntryNumber{$entry}{cfpoolAveScore}\n";
}
