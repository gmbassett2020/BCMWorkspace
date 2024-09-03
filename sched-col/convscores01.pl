#! /usr/bin/perl -w

use lib "/home/gbassett/bfm/perl";
use fbDivI;

# Create the games results from InfoBeat, Massey or Wolfe scores

# Massey:
#09/03/1998      Kentucky Wesleyan        0      Tennessee Tech          52
#2021-01-02  Texas A&M                41  North Carolina           27 P        Orange Bowl Miami, FL


# Wolfe:
#02-Sep-00 AbileneChristian       10 TAMU-Commerce         34 NoRichlandHillsTX

my $thisSeason = shift @ARGV;
my $thisRoundName = shift @ARGV;

my $sched_file = shift @ARGV;
my $score_file = shift @ARGV;

my @score;
if ($score_file ne "-") {
  open SCORE, "$score_file" or die "ERROR opening score file, $score_file ($!)";
  @score = <SCORE>;
  close SCORE or die "ERROR reading schore file, $score_file ($!)";
} else {
  @score = <>;
}

my %scores;
#foreach my $game (grep s/^\s*//, grep s/^\s*\d+\w*\s+//, grep !/:/, @score) {
@score = grep !/:/, @score;
grep s/^\s*(\d+\.?|No\.?\s*\d+\.?)\s+//, @score;
grep s/^\s*//, @score;
grep s/\(.*?-.*?\)//g, @score;
grep s/\(\d+\)//g, @score;
grep s/^.*,.*,.*,.*$//g, @score;
while (@score) {
  my $game = shift @score;

  chomp ($game);
  #$game =~ s/^\s*(\d+\.?|No\.?\s*\d+\.?)\s+//;
  #$game =~ s/^\s*//;
  #$game =~ s/\(.*?-.*?\)//g;
  #$game =~ s/\(\d+\)//g;
  #$game =~ s/^.*,.*,.*,.*$//g;

  my $game2 = $score[0];

  if ($game =~ /^\s*(.*?)\s+(\d+),\s+(.*?)\s+(\d+)/) {

#print "XXX :$1: :$2: :$3: :$4:\n";
    my ($team1, $score1, $team2, $score2) = ($1, $2, $3, $4);
    ($team1, $team2) = std_name_col($team1,$team2);
#print "XXX team1 $team1 team2 $team2\n";
    if ($team1 && $team2) {
      print "WARNING: replacing score for $team1/$team2 of ".
         $scores{"$team1/$team2"} . " with $score1 $score2\n"  
	 if ($scores{"$team1/$team2"} 
	    && $scores{"$team1/$team2"} ne "$score1 $score2");
      $scores{"$team1/$team2"} = "$score1 $score2";
#      print "XXX :$team1/$team2:\n";
    }

  } elsif ($game =~ 
        /^(.*?)\s+(beat|def.|lost to)\s+(No.\s*\d+\s+|)(.*?)\s+(\d+)-(\d+)/) {

#print "XXX $game\n";
    my ($team1, $score1, $team2, $score2) = ($1, $5, $4, $6);
    my $victor = $2;
    if ($victor eq "lost to") {
      ($score1, $score2) = ($score2, $score1);
    }
    ($team1, $team2) = std_name_col($team1,$team2);
#print "XXX team1 $team1 team2 $team2\n";
    if ($team1 && $team2) {
      print "WARNING: replacing score for $team1/$team2 of ".
         $scores{"$team1/$team2"} . " with $score1 $score2\n"  
	 if ($scores{"$team1/$team2"} 
	    && $scores{"$team1/$team2"} ne "$score1 $score2");
      $scores{"$team1/$team2"} = "$score1 $score2";
    }

  # box score
  } elsif ($game =~ /^\s*(.*?)\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+\s+|)?(\d+)\s*$/
       && $game2 =~ /^\s*(.*?)\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+\s+|)?(\d+)\s*$/) {

    $game =~ /^\s*(.*?)\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+\s+|)?(\d+)\s*$/;
    my ($team2, $score2) = ($1,$3);  # $2 is for overtime

    $game2 =~ /^\s*(.*?)\s+\d+\s+\d+\s+\d+\s+\d+\s+(\d+\s+|)?(\d+)\s*$/;
    my ($team1, $score1) = ($1,$3);  # $2 is for overtime
    shift @score;
    ($team1, $team2) = std_name_col($team1,$team2);
    if ($team1 && $team2) {
      print "WARNING: replacing score for $team1/$team2 of ".
         $scores{"$team1/$team2"} . " with $score1 $score2\n"  
	 if ($scores{"$team1/$team2"} 
	    && $scores{"$team1/$team2"} ne "$score1 $score2");
      $scores{"$team1/$team2"} = "$score1 $score2";
    }

  # Massey
  } elsif ($game =~ 
     /^(\d{2}).(\d{2}).\d{4}\s+(.*?)\s{2,}(\d+)\s+(.*?)\s{2,}(\d+)\s+.*$/ ) { 
     print "::: found Massey $game\n";

    my ($mo_num,$day,$team1,$score1,$team2,$score2) = ($1,$2,$3,$4,$5,$6);

    #printf "RAW: %24s %3d    %24s %3d\n", $team1, $score1, $team2, $score2;
    $team1 =~ s/@//;
    $team2 =~ s/@//;
  
    ($team1, $team2) = std_name_col($team1,$team2);
  
    if ($team1 && $team2 ) {
      print "WARNING: replacing score for $team1/$team2 of ".
         $scores{"$team1/$team2"} . " with $score1 $score2\n"  
	 if ($scores{"$team1/$team2"} 
	    && $scores{"$team1/$team2"} ne "$score1 $score2");
      $scores{"$team1/$team2"} = "$score1 $score2";

      #unless ($reverse) {
      #  printf " %.2s %2.2d%3d%1s   %-24s%3d    %-24s\n",
      #         $month[$mo_num-1],$day,$score2,$neutral,$team2,$score1,$team1;
      #} else {
      #  printf " %.2s %2.2d%3d%1s   %-24s%3d    %-24s\n",
      #         $month[$mo_num-1],$day,$score1,$neutral,$team1,$score2,$team2;
      #}
    }
  # Massey 2020
  } elsif ($game =~ 
     /^(\d{4}).(\d{2}).(\d{2})\s+(.*?)\s{2,}(\d+)\s+(.*?)\s{2,}(\d+)(\s+.*|)$/ ) { 

    my ($year,$mo_num,$day,$team1,$score1,$team2,$score2) = ($1,$2,$3,$4,$5,$6,$7);

    #printf "RAW: %24s %3d    %24s %3d\n", $team1, $score1, $team2, $score2;
    #printf "::: massey2021 RAW: %24s %3d    %24s %3d\n", $team1, $score1, $team2, $score2;
    $team1 =~ s/@//;
    $team2 =~ s/@//;
  
    ($team1, $team2) = std_name_col($team1,$team2);
  
    if ($team1 && $team2 ) {
      print "WARNING: replacing score for $team1/$team2 of ".  $scores{"$team1/$team2"} . " with $score1 $score2\n"  if ($scores{"$team1/$team2"} && $scores{"$team1/$team2"} ne "$score1 $score2");
      $scores{"$team1/$team2"} = "$score1 $score2";
      print "::: scores $team1/$team2 $score1-$score2\n";

      #unless ($reverse) {
      #  printf " %.2s %2.2d%3d%1s   %-24s%3d    %-24s\n",
      #         $month[$mo_num-1],$day,$score2,$neutral,$team2,$score1,$team1;
      #} else {
      #  printf " %.2s %2.2d%3d%1s   %-24s%3d    %-24s\n",
      #         $month[$mo_num-1],$day,$score1,$neutral,$team1,$score2,$team2;
      #}
    }

    #$neutral = " ";
    #$reverse = 0;

  # Wolfe
  } elsif ($game =~ 
     /^(\d{2})-(\w{3})-\d{2}\s+(.*?)\s{2,}(\d+)\s+(.*?)\s{2,}(\d+)\s*(.*)$/ ) { 
#2000:
#02-Sep-00 AbileneChristian       10 TAMU-Commerce         34 NoRichlandHillsTX
#09-Sep-00 Vanderbilt             10 Alabama               28 BirminghamAL
#2001:
#25-Aug-01 Peru State              21 Baker                   14 Ellinwood KS

    my ($day,$month,$team1,$score1,$team2,$score2,$n_str) 
        = ($1,$2,$3,$4,$5,$6,$7);

    $team1 =~ s/^\s+//;
    $team2 =~ s/^\s+//;
    $team1 =~ s/\s+$//;
    $team2 =~ s/\s+$//;
    #printf "RAW: %24s %3d    %24s %3d\n", $team1, $score1, $team2, $score2;
  
    #$neutral = "n"  if ($n_str);

    ($team1, $team2) = std_name_col($team1,$team2);

    if ($team1 && $team2 ) {
      print "WARNING: replacing score for $team1/$team2 of ".
         $scores{"$team1/$team2"} . " with $score1 $score2\n"  
	 if ($scores{"$team1/$team2"} 
	    && $scores{"$team1/$team2"} ne "$score1 $score2");
      $scores{"$team1/$team2"} = "$score1 $score2";

      #unless ($reverse) {
      #  printf " %.2s %2.2d%3d%1s   %-24s%3d    %-24s\n",
      #         $month[$mo_num-1],$day,$score2,$neutral,$team2,$score1,$team1;
      #} else {
      #  printf " %.2s %2.2d%3d%1s   %-24s%3d    %-24s\n",
      #         $month[$mo_num-1],$day,$score1,$neutral,$team1,$score2,$team2;
      #}
    }

    #$neutral = " ";
    #$reverse = 0;

  } else {
    #print "WARNING rejecting $game\n";
  }

}

my @sched;
if ($sched_file ne "-") {
  open SCHED, "$sched_file" or die "ERROR opening schedule file, $sched_file ($!)";
  @sched = <SCHED>;
  close SCHED or die "ERROR reading schedule file, $sched_file ($!)";
} else {
  @sched = <>;
}

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
     print "$season,$roundNumber,$roundName,$date_str,$homeFlag,$score1,$team1,$score2,$team2\n";
  }
}

foreach my $unused (sort keys %scores) {
  print "WARNING: unused $unused scores ".$scores{"$unused"}."\n";
}

