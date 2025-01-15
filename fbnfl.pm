#! /usr/bin/perl -w

package         fbnfl;
require         Exporter;
@ISA            = qw(Exporter);
@EXPORT         = qw(std_name_nfl);

use strict;

#=======================================================================
# Subroutine std_name_nfl
#=======================================================================
#  
# This subroutine converts team names into the standard set used by
# the fb program.
#
# USAGE:
#
#    @std_names = std_name_nfl(@raw_names);
#
#    A null string, "", is returned for team names with no match.
#
#=======================================================================

sub std_name_nfl {

my @conv_list = (
  {
    name	=> "Arizona",
    match_str	=> '^(Arizona|Cardinals|ARI)(| Cardinals)$',
  },
  {
    name	=> "Atlanta",
    match_str	=> '^(Atlanta|Falcons|ATL)(| Falcons)$',
  },
  {
    name	=> "Baltimore",
    match_str	=> '^(Baltimore|Ravens|BAL)(| Ravens)$',
  },
  {
    name	=> "Buffalo",
    match_str	=> '^(Buffalo|Bills|BUF)(| Bills)$',
  },
  {
    name	=> "Carolina",
    match_str	=> '^(Carolina|Panthers|CAR)(| Panthers)$',
  },
  {
    name	=> "Chicago",
    match_str	=> '^(Chicago|Bears|CHI)(| Bears)$',
  },
  {
    name	=> "Cincinnati",
    match_str	=> '^(Cincinnati|Bengals|CIN)(| Bengals)$',
  },
  {
    name	=> "Cleveland",
    match_str	=> '^(Cleveland|Browns|CLE)(| Browns)$',
  },
  {
    name	=> "Dallas",
    match_str	=> '^(Dallas|Cowboys|DAL)(| Cowboys)$',
  },
  {
    name	=> "Denver",
    match_str	=> '^(Denver|Broncos|DEN)(| Broncos)$',
  },
  {
    name	=> "Detroit",
    match_str	=> '^(Detroit|Lions|DET)(| Lions)$',
  },
  {
    name	=> "Green Bay",
    match_str	=> '^(Green Bay|Packers|GB)(| Packers)$',
  },
  {
    name	=> "Houston",
    match_str	=> '^(Houston|Texans|HOU)(| Oilers| Texans)$',
  },
  {
    name	=> "Indianapolis",
    match_str	=> '^(Indianapolis|Colts|IND)(| Colts)$',
  },
  {
    name	=> "Jacksonville",
    match_str	=> '^(Jacksonville|Jaguars|JAC)(| Jaguars)$',
  },
  {
    name	=> "Kansas City",
    match_str	=> '^(Kansas City|Chiefs|KC)(| Chiefs)$',
  },
  {
    name	=> "Los Angeles Chargers",
    match_str	=> '^(Los Angeles|Chargers|LAC)(| Chargers)$',
  },
  {
    name	=> "Los Angeles Rams",
    match_str	=> '^(Los Angeles|Rams|LA|LAR)(| Rams)$',
  },
  {
    name	=> "Miami",
    match_str	=> '^(Miami|Dolphins|MIA)(| Dolphins)$',
  },
  {
    name	=> "Minnesota",
    match_str	=> '^(Minnesota|Vikings|MIN)(| Vikings)$',
  },
  {
    name	=> "New England",
    match_str	=> '^(New England|Patriots|NE)(| Patriots)$',
  },
  {
    name	=> "New Orleans",
    match_str	=> '^(New Orleans|Saints|NO)(| Saints)$',
  },
  {
    name	=> "New York Giants",
    match_str	=> '^(NYG|(New York|N\.? ?Y\.?|Giants|) ?Giants)$',
  },
  {
    name	=> "New York Jets",
    match_str	=> '^(NYJ|(New York|N\.? ?Y\.?|Jets|) ?Jets)$',
  },
  {
    name	=> "Las Vegas",
    match_str	=> '^(Oakland|Raiders|OAK|Las Vegas|LV)(| Raiders)$',
  },
  {
    name	=> "Philadelphia",
    match_str	=> '^(Philadelphia|Eagles|PHI)(| Eagles)$',
  },
  {
    name	=> "Pittsburgh",
    match_str	=> '^(Pittsburgh|Steelers|PIT)(| Steelers)$',
  },
  {
    name	=> "San Diego",
    match_str	=> '^(San Diego|Chargers|SD)(| Chargers)$',
  },
  {
    name	=> "San Francisco",
    match_str	=> '^(San Francisco|49ers|SF)(| 49ers)$',
  },
  {
    name	=> "Seattle",
    match_str	=> '^(Seattle|Seahawks|SEA)(| Seahawks)$',
  },
  {
    name	=> "St. Louis",
    match_str	=> '^St\.? Louis(| Rams)$',
  },
  {
    name	=> "Tampa Bay",
    match_str	=> '^(Tampa Bay|Buccaneers|TB)(| Buccaneers)$',
  },
  {
    name	=> "Tennessee",
    match_str	=> '^(Tennessee|Titans|TEN)(| Oilers| Titans)$',
  },
  {
    name	=> "Washington",
    match_str	=> '^(Washington|Redskins|WAS|Football Team|Commanders)(| (Redskins|Football Team|Commanders))$',
  },
);

my @names_out;
my $name;
foreach $name (@_) {

#print "LOOKING for $name\n";
  die "ERROR: ambiguous name $name" if ($name eq "Los Angeles");

  my $team;
  my $match;
  foreach $team (@conv_list) {
#print "TEAM $team->{name} MATCH $team->{match_str}\n";
    if ($name =~ /$team->{match_str}/i) {
      push @names_out, $team->{name};
      $match = 1;
      last;
#print "FOUND $team->{name}\n";
    } 
  }
  unless ($match) {
    print "WARNING: $name not found\n";
    push @names_out, "";
  }
}

return @names_out;

}
