#! /usr/bin/perl -w

#use lib "/home/gbassett/bfm/perl";
use lib "./";
use fbnfl;

use strict;

# Create the games results from InfoBeat scores
# or scores from http://www.supernfl.com/NFLscores.html.

# 2016+: https://sports.yahoo.com/nfl/scoreboard/

my $thisSeason = shift @ARGV;
my $thisRoundName = shift @ARGV;

my $sched_file = shift @ARGV;
my $score_file = shift @ARGV;

my $score_out_file = shift @ARGV;

open SCORE, "$score_file" or die "ERROR opening score file, $score_file ($!)";
my @score = <SCORE>;
close SCORE or die "ERROR reading score file, $score_file ($!)";

open OUT, ">$score_out_file" or die "ERROR opening score out file, $score_out_file ($!)";

#my $foxSports = grep /FOX/, @score;
#FIXME:
my $foxSports = 0;
my $yahoo2016 = 1;

sub trim_game
{
  my $game = shift @_;
  chomp ($game);
  $game =~ s/^\s*(\d+\.?|No\.?\s*\d+\.?)\s+//;
  $game =~ s/^\s*//;
  $game =~ s/\(.*?-.*?\)//g;
  $game =~ s/\(.*?-.*?\)//g;
  $game =~ s/\(\d+\)//g;
  $game =~ s/^.*,.*,.*,.*$//g;
  $game =~ s/\d+-\d+(|-\d)\s+//g;
  $game =~ s/^\*\*//;

  return $game;
}

my %scores;
#foreach my $game (grep s/^\s*//, grep s/^\s*\d+\w*\s+//, grep !/:/, @score) {
@score = grep !/:/, @score;
while (@score) {
  if ($yahoo2016)
  {
     if ($score[0] !~ /\d/ && $score[0] =~ /\S/
      && $score[1] =~ /\S/
      && $score[2] =~ /^\s*\d+\s*$/ 
      && $score[3] !~ /\S/
      && $score[4] !~ /\d/ && $score[4] =~ /\S/
      && $score[5] =~ /\S/
      && $score[6] =~ /^\s*\d+\s*$/)
     {
       chomp($score[0]);
       chomp($score[1]);
       chomp($score[2]);
       chomp($score[3]);
       chomp($score[4]);
       chomp($score[5]);
       chomp($score[6]);
       my $team1 = $score[0] . " " . $score[1];
       my $score1 = $score[2];
       my $team2 = $score[4] . " " . $score[5];
       my $score2 = $score[6];
       shift @score;
       shift @score;
       shift @score;
       shift @score;
       shift @score;
       shift @score;
       ($team1, $team2) = std_name_nfl($team1,$team2);
       $scores{"$team1/$team2"} = "$score1 $score2";
     }
     else
     {
        shift @score;
        @score = () if scalar(@score) < 8;
     }
  }
  else
  {
    my $game = shift @score;
    $game = trim_game($game);
    
    my $game2 = trim_game($score[0]);
  
  #print "XXX line: $game\n";
  
    if ($foxSports)
    # http://www.foxsports.com/nfl/scores
    {
       my ($team1, $team1b, $blank, $team2, $team2b) = @score;
       my ($score1, $score2);
       if (scalar(@score) >= 5 && $blank !~ /\S/)
       {
          chomp($team1) if ($team1);
          chomp($team2) if ($team2);
          if ($team1b =~ /(\S+)\(.*\)\s+(\d+)/)
          {
             $team1 .= " ".$1;
             $score1 = $2;
  
             if ($team2b =~ /(\S+)\(.*\)\s+(\d+)/)
             {
                $team2 .= " ".$1;
                $score2 = $2;
  
                shift @score;
                shift @score;
                shift @score;
                shift @score;
  
                ($team1, $team2) = std_name_nfl($team1,$team2);
                if ($team1 && $team2) {
                  print "WARNING: replacing score for $team1/$team2 of ".
                     $scores{"$team1/$team2"} . " with $score1 $score2\n"  
                     if ($scores{"$team1/$team2"} 
                        && $scores{"$team1/$team2"} ne "$score1 $score2");
                  $scores{"$team1/$team2"} = "$score1 $score2";
                }
             }
          }
       }
    }
    elsif ($game =~ /^\s*(.*?)\s+(\d+),\s+(.*?)\s+(\d+)(\s|,|$)/) 
    {
  
  #print "XXX :$1: :$2: :$3: :$4:\n";
      my ($team1, $score1, $team2, $score2) = ($1, $2, $3, $4);
      ($team1, $team2) = std_name_nfl($team1,$team2);
  #print "XXX team1 $team1 team2 $team2\n";
      if ($team1 && $team2) {
        print "WARNING: replacing score for $team1/$team2 of ".
           $scores{"$team1/$team2"} . " with $score1 $score2\n"  
  	 if ($scores{"$team1/$team2"} 
  	    && $scores{"$team1/$team2"} ne "$score1 $score2");
        $scores{"$team1/$team2"} = "$score1 $score2";
  #      print "XXX :$team1/$team2:\n";
      }
  
    } 
    elsif ($game =~ 
          /^(.*?)\s+(beat|def.|lost to)\s+(No.\s*\d+\s+|)(.*?)\s+(\d+)-(\d+)/) 
    {
  #print "XXX1 $game\n";
      my ($team1, $score1, $team2, $score2) = ($1, $5, $4, $6);
      my $victor = $2;
      if ($victor eq "lost to") {
        ($score1, $score2) = ($score2, $score1);
      }
      ($team1, $team2) = std_name_nfl($team1,$team2);
  #print "XXX team1 $team1 team2 $team2\n";
      if ($team1 && $team2) {
        print "WARNING: replacing score for $team1/$team2 of ".
           $scores{"$team1/$team2"} . " with $score1 $score2\n"  
  	 if ($scores{"$team1/$team2"} 
  	    && $scores{"$team1/$team2"} ne "$score1 $score2");
        $scores{"$team1/$team2"} = "$score1 $score2";
      }
  
    # box score
    } 
    elsif ($game =~ /^\s*(.*?)\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+\s+|)?(\d+)\s*$/
         && $game2 =~ /^\s*(.*?)\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+\s+|)?(\d+)\s*$/) 
    {
  #print "XXX2 box\n";
  
      $game =~ /^\s*(.*?)\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+\s+|)?(\d+)\s*$/;
      my ($team2, $score2) = ($1,$3);  # $2 is for overtime
  
      $game2 =~ /^\s*(.*?)\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+\s+|)?(\d+)\s*$/;
      my ($team1, $score1) = ($1,$3);  # $2 is for overtime
      shift @score;
  
      ($team1, $team2) = std_name_nfl($team1,$team2);
      if ($team1 && $team2) {
        print "WARNING: replacing score for $team1/$team2 of ".
           $scores{"$team1/$team2"} . " with $score1 $score2\n"  
  	 if ($scores{"$team1/$team2"} 
  	    && $scores{"$team1/$team2"} ne "$score1 $score2");
        $scores{"$team1/$team2"} = "$score1 $score2";
      }
  
    # <team 1> <scr1> at/vs <team 2> <scr2>
    } 
    elsif ($game =~ 
          /^(.*?)\s+(\d+)\s+(at|vs)\s+(.*?)\s+(\d+)/) 
    {
  #print "XXX3 $game\n";
      my ($team1, $score1, $team2, $score2) = ($1, $2, $4, $5);
  #print "XXX 1:$1: 2:$2: 3:$3: 4:$4: 5:$5:\n";
      ($team1, $team2) = std_name_nfl($team1,$team2);
  #print "XXX team1 $team1 team2 $team2\n";
      if ($team1 && $team2) {
        print "WARNING: replacing score for $team1/$team2 of ".
           $scores{"$team1/$team2"} . " with $score1 $score2\n"  
  	 if ($scores{"$team1/$team2"} 
  	    && $scores{"$team1/$team2"} ne "$score1 $score2");
        $scores{"$team1/$team2"} = "$score1 $score2";
      }
  
    # team1 score1
    # team2 score2
    } 
    elsif ($game =~ /^\s*(.*?)\s+(\d+)\s*$/
         && $game2 =~ /^\s*(.*?)\s+(\d+)\s*$/) 
    {
  #print "XXX2 box\n";
  
      $game =~ /^\s*(.*?)\s+(\d+)\s*$/;
      my ($team2, $score2) = ($1,$2);
  
      $game2 =~ /^\s*(.*?)\s+(\d+)\s*$/;
      my ($team1, $score1) = ($1,$2);
      shift @score;
  
      ($team1, $team2) = std_name_nfl($team1,$team2);
      if ($team1 && $team2) {
        print "WARNING: replacing score for $team1/$team2 of ".
           $scores{"$team1/$team2"} . " with $score1 $score2\n"  
  	 if ($scores{"$team1/$team2"} 
  	    && $scores{"$team1/$team2"} ne "$score1 $score2");
        $scores{"$team1/$team2"} = "$score1 $score2";
      }
  
    } else {
      print "WARNING rejecting $game\n";
    }
  }

}

foreach my $teams (sort keys %scores)
{
   print "::: teams $teams score $scores{$teams}\n";
}

open SCHED, "$sched_file" or die "ERROR opening schedule file, $sched_file ($!)";
my @sched = <SCHED>;
close SCHED or die "ERROR reading schedule file, $sched_file ($!)";

#foreach my $match (sort keys %scores) {
#  print "XXX match $match scores ". $scores{"$match"} ."\n";
#}

foreach my $game (@sched) {
# Au 28 41    Florida State             7    Louisiana Tech          
 
  my ($season, $roundNumber, $roundName, $date_str, $homeFlag, $score1, $team1, $score2, $team2) = split /,/, $game;
  chomp($team2);
  if ($season eq $thisSeason && $roundName eq $thisRoundName)
  {
     if (defined $scores{"$team1/$team2"}) {
       $scores{"$team1/$team2"} =~ /^(\d+)\s+(\d+)$/;
       if ($score1+$score2 > 0 && ($score1 != $1 || $score2 != $2)) {
         print "WARNING: old score differs from new one: $team1 vs $team2\n";
         print "   old $score1-$score2   new $1-$2\n";
       }
       ($score1, $score2) = ($1, $2);
       delete $scores{"$team1/$team2"};
     } elsif (defined $scores{"$team2/$team1"}) {
       $scores{"$team2/$team1"} =~ /^(\d+)\s+(\d+)$/;
       if ($score1+$score2 > 0 && ($score1 != $2 || $score2 != $1)) {
         print "WARNING: old score differs from new one: $team1 vs $team2\n";
         print "   old $score1-$score2   new $2-$1\n";
       }
       ($score1, $score2) = ($2, $1);
       delete $scores{"$team2/$team1"};
     } else {
       print "ERROR: missing game $game\n";
     }
     print OUT "$season,$roundNumber,$roundName,$date_str,$homeFlag,$score1,$team1,$score2,$team2\n";
  }
}

foreach my $unused (sort keys %scores) {
  print OUT "WARNING: unused $unused scores ".$scores{"$unused"}."\n";
}

close OUT;
