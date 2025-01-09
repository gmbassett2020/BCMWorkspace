#! /usr/bin/perl -w

#use lib "/home/gbassett/bfm/perl";
use lib "./";
use fbnfl;

$| = 1; #OUTPUT_AUTOFLUSH

# Create a game schedule from USA Football Center Online

# try?: http://www.foxsports.com/nfl/schedule?season=2015

my ($schedFileIn, $schedFileOut) = @ARGV;

open IN, "<$schedFileIn" or die "ERROR opening input file $schedFileIn ($!)";
my @sched = <IN>;
close IN;

open OUT, ">$schedFileOut" or die "ERROR opening output file $schedFileOut ($!)";

my ($team1, $team2, $score1, $score2);
my ($month, $day);
my $neutral = "team1Home";
my $reverse = 1;

my %mo_num = (
  "Jan" => "01", "Feb" => "02", "Mar" => "03", "Apr" => "04", "May" => "05",
  "Jun" => "06", "Jul" => "07", "Aug" => "08", "Sep" => "09", "Oct" => "10",
  "Nov" => "11", "Dec" => "12",
); 
my $wkdy_match = 'mon|tue|wed|thu|fri|sat|sun';
my $mo_match = 'jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec';

my $year;
my $yr = "00";
my $week;
my $week_num = 0;

my @week_names = ("weekb1", "week02", "week03", "week04", "week05", "week06", "week07", "week08", "week09", "week10", "week11", "week12", "week13", "week14", "week15", "week16", "week17", "week18", "weeke1", "weeke2", "weeke3", "weeke4");

print OUT "Season,RoundNumber,RoundName,Date,HomeFlag,Score1,Team1,Score2,Team2\n";

#foreach my $game (@sched) {
while (@sched) {

  my $game = shift @sched;
  my $rawGame = $game;

  print "::: $rawGame eq $sched[0] && $sched[2] eq $sched[3]\n";

  chomp ($game);
  $game =~ s/\r//g;

  if ($game =~ /neutral/i) {

      $neutral = "neutral";

  } elsif ($game =~ /reverse/i) {

    $reverse = 0;

  } elsif ($game =~ /^\s*(\d{4})\s+nfl\s+schedule/i) {

    $year = $1;
    $yr = $year;
    $yr =~ s/^..//;

  } elsif ($game =~ /^\s*(\d{4}).*regular season/i) {

    $year = $1;
    $yr = $year;
    $yr =~ s/^..//;

  } elsif ($game =~ /^\s*week\s+(\d+)/i) {
     
    $week = $1;
    $week_num = $week;
#    printf "::: %swk%02d\n", $yr, $week;

  } elsif 
     ($game =~ /^\s*($wkdy_match|)\S*\s*($mo_match)\S*\s+(\d+)/i) {

    my $mo_str = ucfirst(lc($2));
    if ($mo_num{"$mo_str"}) {
      $day = $3;
      $month = $mo_num{"$mo_str"};
#     print "DATE: $month/$day\n";
    } else {
      print "WARNING: bad date: $game, mo_str $mo_str day $day\n";
    }

  } elsif 
     ($game =~ /^\s*($wkdy_match|)\S*\s*(\d+)\S*?\s+($mo_match)/i) {

    my $mo_str = ucfirst(lc($3));
    if ($mo_num{"$mo_str"}) {
      $day = $2;
      $month = $mo_num{"$mo_str"};
#     print "DATE: $month/$day\n";
    } else {
      print "WARNING: bad date: $game, mo_str $mo_str day $day\n";
    }

#  } elsif ($game =~ /^\s*(.*?)\s+(at|vs\.?)\s+(No.\s*\d+\s+|)(.*?)\s*(,|\(|\d+:\d+\s*(am|pm|a.m.|p.m.))/i) {
#    
#    $team1 = $4;
#    $team2 = $1;
#    $place_str = $2;
#    if ($place_str =~ /vs/i) {
#      $neutral = "neutral";
#    }
##   print "TEAMS raw: 1 $team1 2 $team2 place $place_str\n";
#
#    ($team1, $team2) = std_name_nfl($team1,$team2);
#
#    if ($team1 && $team2 ) {
#      unless ($reverse) {
#         printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
#            $year,$week_num-1,$week_names[$week_num-1],$year,$month,$day,$neutral,$team2,$team1;
#      } else {
#         printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
#            $year,$week_num-1,$week_names[$week_num-1],$year,$month,$day,$neutral,$team1,$team2;
#      }
#    }
#
#    $neutral = "team1Home";
#    $reverse = 1;
#
#  } elsif ($game =~ /^[A-Z]{2,3}$/ && $sched[1] =~ /\@/ && $sched[2] =~ /^[A-Z]{2,3}$/) {
#    # https://www.usatoday.com/sports/nfl/schedule/2018/season-regular/all/
#    # copy page and paste as text
#    $team1 = $game;
#    $team2 = $sched[2];
#    chomp ($team2);
#    shift @sched;
#    shift @sched;
#    shift @sched;
#    shift @sched;
#
#    ($team1, $team2) = std_name_nfl($team1,$team2);
#
#    if ($team1 && $team2 ) {
#      printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
#         $year,$week_num-1,$week_names[$week_num-1],$year,$month,$day,$neutral,$team2,$team1; # always reverse
#    }
#
#    $neutral = "team1Home";
#
#  } elsif ($sched[0] =~ /^[A-Z]{2,3}$/ && $sched[1] =~ /\@/ && $sched[2] =~ /^[A-Z]{2,3}$/) {
#    # 2020 https://sportsdata.usatoday.com/football/nfl/schedule
#    # copy page and paste as text
#    $team1 = $sched[0];
#    $team2 = $sched[2];
#    chomp ($team1);
#    chomp ($team2);
#    shift @sched;
#    shift @sched;
#    shift @sched;
#
#    ($team1, $team2) = std_name_nfl($team1,$team2);
#
#    if ($team1 && $team2 ) {
#      printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
#         $year,$week_num-1,$week_names[$week_num-1],$year,$month,$day,$neutral,$team2,$team1; # always reverse
#    }
#
#    $neutral = "team1Home";
#
#  } elsif ($game =~ /team-logo/) {
#    # 2020 https://www.foxsports.com/nfl/scores
#    # copy page and paste as text
#    $team1 = shift @sched;
#    my $count = 0;
#    while ($sched[0] !~ /team-logo/ && $count < 4)
#    {
#       shift @sched;
#       $count += 1;
#    }
#    shift @sched;
#    die "ERROR parsing second team" if ($count >= 4);
#    $team2 = shift @sched;
#    
#    chomp ($team1);
#    chomp ($team2);
#
#    ($team1, $team2) = std_name_nfl($team1,$team2);
#
#    if ($team1 && $team2 ) {
#      printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
#         $year,$week_num-1,$week_names[$week_num-1],$year,$month,$day,$neutral,$team2,$team1; # always reverse
#    }
#
#    $neutral = "team1Home";

  } elsif (($rawGame eq $sched[0]) && ($sched[2] eq $sched[3])) {
  print "::: found matchup\n";
    # 2021 https://www.foxsports.com/nfl/scores
    # copy page and paste as text
    # problems with the end of the season - need to make similar names identical
    # see 2021 espn
    $team1 = $game;
    shift @sched;
    shift @sched;
    $team2 = shift @sched;
    shift @sched;
    
    chomp ($team1);
    chomp ($team2);

    ($team1, $team2) = std_name_nfl($team1,$team2);

#print "::: team1=$team1 team2=$team2\n";
    if ($team1 && $team2 ) {
      printf OUT "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
         $year,$week_num-1,$week_names[$week_num-1],$year,$month,$day,$neutral,$team2,$team1; # always reverse
    }

    $neutral = "team1Home";

  } elsif ($sched[0] =~ /^\t[A-Z]/ && $sched[1] =~ /^\t[A-Z]/) {
    # 2021 https://www.espn.com/nfl/schedule
    # for each week, copy page and paste as text
    # this has issue with duplicate city names -- can't use this without checking those games
    # used for the January games, adding distinguishing name manually
    $team1 = shift @sched;
    $team1 =~ s/\t//g;
    $team1 =~ s/\s+$//;
    $team2 = shift @sched;
    $team2 =~ s/\t//g;
    $team2 =~ s/\s+$//;
    
    chomp ($team1);
    chomp ($team2);

    ($team1, $team2) = std_name_nfl($team1,$team2);

    if ($team1 && $team2 ) {
      printf OUT "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
         $year,$week_num-1,$week_names[$week_num-1],$year,$month,$day,$neutral,$team2,$team1; # always reverse
    }

    $neutral = "team1Home";

  } else {
#    print "::: ignoring: $game\n";
  }

}

close OUT;

