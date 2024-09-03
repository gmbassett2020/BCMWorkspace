#! /usr/bin/perl -w

use lib "/home/gbassett/bfm/perl";
use fbDivI;

use POSIX qw/strftime/;

use strict;

my %mo_num = (
  "Jan" => "01", "Feb" => "02", "Mar" => "03", "Apr" => "04", "May" => "05",
  "Jun" => "06", "Jul" => "07", "Aug" => "08", "Sep" => "09", "Oct" => "10",
  "Nov" => "11", "Dec" => "12",
); 

# Create a game schedule from InfoBeat email,
# CBS Sportsline,
# or Wolfe schedule format
# or Massey format

my @sched = <>;
my ($team1, $team2, $score1, $score2);
my ($month, $day, $year);
my $neutral = "team1Home";

my $week_string = "";
my $week_num;
my $week_time;
my $week_time0;

print "Season,RoundNumber,RoundName,Date,HomeFlag,Score1,Team1,Score2,Team2\n";

sub update_week
{

  my ($day, $month, $year) = @_;

  my ($time) = `date +%s -d "$year-$month-$day"`;

  my $dow = strftime('%a',localtime($time));

  my $seconds_per_day = 3600*24;

  my %dow_adjust = (
      "Sun" => - $seconds_per_day * 5,
      "Mon" => - $seconds_per_day * 6,
      "Tue" => - $seconds_per_day * 0,
      "Wed" => - $seconds_per_day * 1,
      "Thu" => - $seconds_per_day * 2,
      "Fri" => - $seconds_per_day * 3,
      "Sat" => - $seconds_per_day * 4
  );

  my $this_week_time = $time + $dow_adjust{$dow};

  if (! defined $week_time)
  {
    $week_time0 = $this_week_time - $seconds_per_day * 7;
    $week_time = $week_time0;
  }

  if ($week_time != $this_week_time)
  {
    my $yr = $year; # note that this will not be right for January games
    $yr =~ s/.*(\d\d)$/$1/;
    $week_num = ($this_week_time - $week_time0)/($seconds_per_day*7);
    my $week_string = sprintf "%2.2dwk%2.2d", $yr, $week_num - 1; # take one off to start with preseason week 0
    #print "$week_string\n";
    $week_time = $this_week_time;
  }
}

#foreach my $game ( grep !/:/, @sched) { #}
foreach my $game (@sched) {
#print "XXX game $game";

  my $reverse;

  chomp ($game);
  $game =~ s/^\s*(\d+\.?|No\.?\s*\d+\.?)\s+//;
  $game =~ s/^\s*//;
  $game =~ s/\(\d.*?\)//g;
#print "XXX game: $game\n";

  if ($game =~ /^\s*neutral/i) {

      $neutral = "neutral";

  } elsif ($game =~ /^\s*reverse/i) {

    $reverse = 1;

  } elsif ($game =~ /^\s*(sun|mon|tue|wed|thu|fri|sat)\S* (\S{3})\S* (\d+)/i) {
#print "XXX date ...\n";

    $day = $3;
    #$month = lc ($2);
    #$month = ucfirst ($month);
    my $mo_str = ucfirst (lc($2));
    if ($mo_num{"$mo_str"}) {
      $month = $mo_num{"$mo_str"};
#      print "DATE: $month/$day\n";
    } else {
      print "WARNING: bad date: $game, mo_str $mo_str day $day\n";
    }

  } elsif ($game =~ 
     /^(\d\d)-(\S{3})-(\d\d)\s+(\S.*?)\s{2,}(\S.*?)(\s*|\s{2,}(\S.*?))$/) {
     # Wolfe

    if (defined $reverse) { # Wolfe is flipped with home listed second
      $reverse = 0;
    } else {
      $reverse = 1;
    }
    
#print "XXX wolfe 1 $1 2 $2 3 $3 4 $4 5 $5 6 $6 7 $7\n";
    $day = $1;
    #$month = lc ($2);
    #$month = ucfirst ($month);
    my $mo_str = ucfirst (lc($2));
    if ($mo_num{"$mo_str"}) {
      $month = $mo_num{"$mo_str"};
#      print "DATE: $month/$day\n";
    } else {
      print "WARNING: bad date: $game, mo_str $mo_str day $day\n";
    }
    my $yr = $3;
    if ($yr < 50)
    {
      $year = 1900+$yr;
    }
    else
    {
      $year = 2000+$yr;
    }

    $team1 = $4;
    $team2 = $5;
    my $place_str = $7;
    if ($place_str) {
      $neutral = "neutral";
    }

    ($team1, $team2) = std_name_col($team1,$team2);

    if ($team1 && $team2 ) {

      update_week($day, $month, $year);
      my $week_name = sprintf("week%2.2d", $week_num-1);
      $week_name =~ s/week0/weekb/ if ($week_num < 3);


      unless ($reverse) {
#print "XXX reverse\n";
        printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
               $year,$week_num-1,$week_name,$year,$month,$day,$neutral,$team1,$team2;
      } else {
        printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
               $year,$week_num-1,$week_name,$year,$month,$day,$neutral,$team2,$team1;
      }
    }

    $neutral = "team1Home";

  } elsif ($game =~ 
     /^(\d\d)\/(\d\d)\/(\d{4})\s+(\S.*?)\s+(\d+)\s+(\S.*?)\s+(\d+)(\s+\@.*|)$/) {
     # Howell

#print "XXX howell d $1 m $2 y $3 t1 $4 s1 $5 t2 $6 s2 $7 n $8\n";

    $reverse = 1 unless defined ($reverse);
    
    $day = $2;
    my $mo_num = $1;
    $year = $3;

    $team1 = $4;
    $team2 = $6;
    $score1 = $5;
    $score2 = $7;
    my $place_str = $8;
    if ($place_str) {
      $neutral = "neutral";
    }

    ($team1, $team2) = std_name_col($team1,$team2);

    if ($team1 && $team2 ) {
      update_week($day, $mo_num, $year);
      my $week_name = sprintf("week%2.2d", $week_num-1);
      $week_name =~ s/week0/weekb/ if ($week_num < 3);

      unless ($reverse) {
#print "XXX reverse\n";
        printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,%d,%s,%d,%s\n",
               $year,$week_num-1,$week_name,$year,$month,$day,$neutral,$score1,$team1,$score2,$team2;
      } else {
        printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,%d,%s,%d,%s\n",
               $year,$week_num-1,$week_name,$year,$month,$day,$neutral,$score2,$team2,$score1,$team1;
      }
    }

    $neutral = "team1Home";

  # Massey https://www.masseyratings.com/scores.php?s=cf2020&sub=ncaa-d1&all=1&sch=on
  # 2020-11-14  South Florida             0 @Houston                   0 Sch 
  } elsif ($game =~ 
     /^(\d\d\d\d)-(\d\d)-(\d\d)\s+(\S.*?)\s{2,}(\d+)\s(.)(\S.*?)\s{2,}(\d+)/) {

    my ($year, $month, $day, $team1, $score1, $place_str, $team2, $score2) = ($1, $2, $3, $4, $5, $6, $7, $8);
    
#print "::: massey 1 $1 2 $2 3 $3 4 $4 5 $5 6 $6 7 $7 8 $8\n";

    if (defined $reverse) { # Massey is flipped with home listed second
      $reverse = 0;
    } else {
      $reverse = 1;
    }
    if ($place_str ne "@") {
      $neutral = "neutral";
    } else {
      $neutral = "team1Home";
    }
    # new format indicating home field with @ at the beginning of the team name
    if ($team1 =~ s/^@//)
    {
       $reverse = 0;
       $neutral = "team1Home";
    }
    elsif ($team2 =~ s/^@//)
    {
       $reverse = 1;
       $neutral = "team1Home";
    }

    ($team1, $team2) = std_name_col($team1,$team2);

    if ($team1 && $team2 ) {

      update_week($day, $month, $year);
      my $week_name = sprintf("week%2.2d", $week_num-1);
      $week_name =~ s/week0/weekb/ if ($week_num < 3);

      unless ($reverse) {
        printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
               $year,$week_num-1,$week_name,$year,$month,$day,$neutral,$team1,$team2;
      } else {
        printf "%d,%d,%s,%4s-%2.2s-%2.2d,%s,-1,%s,-1,%s\n",
               $year,$week_num-1,$week_name,$year,$month,$day,$neutral,$team2,$team1;
      }
    }

  } elsif ($game =~ /^\s*(.*?)\s*$/) {

    my $team_in = $1;
    unless (! defined $team_in || $team_in =~ /\d/) {
      $team_in = std_name_col($team_in);
      $team1 = $team_in if ($team_in);
    }
  }

}
