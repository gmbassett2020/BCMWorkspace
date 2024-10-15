
Location of the model and scripts:

   https://github.com/gmbassett2020/BassettCompetativeModel
   https://github.com/gmbassett2020/BCMWorkspace


Tools needed:

   AnacondaPython
   Strawberry Perl
   NotePad++ (or another text editor)

maxRound is the round (1 based) on which to do predictions.

######
# nfl
######

The model takes two files as input:
   + nfl-seasons-2001_<year>.csv 
   + nfl-list-2001_<year>.csv

Setup season (create seasons and list files with updated schedule and conference info):

   + from https://www.foxsports.com/nfl/scores
      + for each week, copy the listing of games and then paste into <year>foxSched.txt
   + See 2023foxSched.txt for what to add between each week (to make the perl script happy):
      One blank line, right after previous week's content
      week <weekNumber>
      One blank line, right before next week's content

   + convert to CSV format:
      C:\Strawberry\perl\bin\perl.exe convschednfl.pl <year>foxSched.txt <year>Sched.out

   + copy nfl-seasons-2001_<year-1>.csv to nfl-seasons-2001_<year>.csv
   + Add the contents of Sched.out to nfl-seasons-2001_<year>.csv, leaving off the header line at the top of <year>Sched.out.

   + Update the list file which sets the conference for each team.  
      + copy nfl-list-2001_<year-1>.csv to nfl-list-2001_<year>.csv
      + For any team which has changed conference, or for new teams, add a line to the list csv. E.g. If Seattle changed to NFC West, add:
         Seattle,2024,NFC,West

Add each week into makeweb.pl

   + search for "# NFL dates"
   + copy the previous season's week entries and change date and week descriptions with the current season.

Weekly:


Update with previous week's scores:
   + Copy scores from https://sports.yahoo.com/nfl/scoreboard/?confId=&schedState=2&dateRange=2 into scores-in.txt

   
   + Convert the scores into the format used in nfl-seasons-2001_<year>.csv and merge into that csv (replace the rows):
      ./convscoresnfl.pl 2024 weekb1 nfl-seasons-2001_2024.csv scores-in.txt >  scores-out.txt
      ...
      ./convscoresnfl.pl 2024 week16 nfl-seasons-2001_2024.csv scores-in.txt >  scores-out.txt
      ./convscoresnfl.pl 2024 week17 nfl-seasons-2001_2024.csv scores-in.txt >  scores-out.txt
      ...
      ./convscoresnfl.pl 2024 weeke4 nfl-seasons-2001_2024.csv scores-in.txt >  scores-out.txt

   + Add week information for current year in makeweb.pl:
      + search for "# NFL dates" and add the 3 lines for the current week.  E.g.

   $info{nfl}{2024}{wkb1}{date_str} = "Week 1 (5-9 Sep)";
   $info{nfl}{2024}{wkName}{$wk_count} = "wkb1";
   $info{nfl}{2024}{wkb1}{wk_num} = $wk_count++;
   ...
   $info{nfl}{2024}{wk18}{wk_num = $wk_count++;

update nfl-seasons*.csv with scores-out.txt content

# Generate forecast for current week:

Note that the output file, e.g. nfl-24wk01.txt is used by the perl script makeweb.pl with the 
file naming being important, i.e. <league>-<yr>wk<wk>.txt.

# first week
# note the week in the output file is "b1"
python forecastAndRank.py currentSeason=2024 maxRound=1 useTeamListFile=nfl-list-2001_2024.csv useTeamSeasonsFile=nfl-seasons-2001_2024.csv outputFile=nfl-24wkb1.txt
# second week
# note the week in the output file is "02"
python forecastAndRank.py currentSeason=2024 maxRound=2 useTeamListFile=nfl-list-2001_2024.csv useTeamSeasonsFile=nfl-seasons-2001_2024.csv outputFile=nfl-24wk02.txt
...
# last weeks
python forecastAndRank.py currentSeason=2024 maxRound=18 useTeamListFile=nfl-list-2001_2024.csv useTeamSeasonsFile=nfl-seasons-2001_2024.csv outputFile=nfl-24wk18.txt
# note that for playoffs, the week for the output files is "e1", "e2", ...
python forecastAndRank.py currentSeason=2024 maxRound=19 useTeamListFile=nfl-list-2001_2024.csv useTeamSeasonsFile=nfl-seasons-2001_2024.csv outputFile=nfl-24wke1.txt
python forecastAndRank.py currentSeason=2024 maxRound=20 useTeamListFile=nfl-list-2001_2024.csv useTeamSeasonsFile=nfl-seasons-2001_2024.csv outputFile=nfl-24wke2.txt
python forecastAndRank.py currentSeason=2024 maxRound=21 useTeamListFile=nfl-list-2001_2024.csv useTeamSeasonsFile=nfl-seasons-2001_2024.csv outputFile=nfl-24wke3.txt
python forecastAndRank.py currentSeason=2024 maxRound=22 useTeamListFile=nfl-list-2001_2024.csv useTeamSeasonsFile=nfl-seasons-2001_2024.csv outputFile=nfl-24wke4.txt

# Update makeweb.pl with current week and year:
   my $year = "2023";
   my $league = "nfl";
   my $week = "weeke4"; # this is the current week, the result week is one less
   my $today = "30 Jan 2024";

# makeweb.pl: If not already present, also add the current week to the info hash. Search for "# NFL dates" and add the 3 lines for the current week.  E.g.

   $info{nfl}{2024}{wkb1}{date_str} = "Week 1 (5-9 Sep)";
   $info{nfl}{2024}{wkName}{$wk_count} = "wkb1";
   $info{nfl}{2024}{wkb1}{wk_num} = $wk_count++;


Run:
C:\Strawberry\perl\bin\perl.exe makeweb.pl

# Update the web site:
scp *.html <userAndSiteWithPath>/.


######
# col
######

Setup season
   + Update team and conference info in list file
   + Download massey schedule/scores: https://masseyratings.com/scores.php?s=cf2024&sub=ncaa-i&all=1&sch=on
   + Run convschedcol.pl capturing schedule from STDOUT and removing WARNING.
   + Add schedule to the seasons file.
   + Run checkschedule.pl to ensure all team names are properly parsed (no teams with no games or a small number of games in their schedule).
      perl checksched.pl ../colI-seasons-2020_2024.csv ../colI-list-2020_2024.csv 2024

update scores
in sched-col
  doScores.csh


python forecastAndRank.py currentSeason=2024 maxRound=1 useTeamListFile=workspace/colI-list-2020_2024.csv useTeamSeasonsFile=workspace/colI-seasons-2020_2024.csv outputFile=workspace/col-24wkb0.txt usePowerUncertainty=True |& tee tmp.txt
python forecastAndRank.py currentSeason=2024 maxRound=2 useTeamListFile=workspace/colI-list-2020_2024.csv useTeamSeasonsFile=workspace/colI-seasons-2020_2024.csv outputFile=workspace/col-24wkb1.txt usePowerUncertainty=True |& tee tmp.txt
python forecastAndRank.py currentSeason=2024 maxRound=3 useTeamListFile=workspace/colI-list-2020_2024.csv useTeamSeasonsFile=workspace/colI-seasons-2020_2024.csv outputFile=workspace/col-24wk02.txt usePowerUncertainty=True |& tee tmp.txt
...
python forecastAndRank.py currentSeason=2024 maxRound=16 useTeamListFile=workspace/colI-list-2020_2024.csv useTeamSeasonsFile=workspace/colI-seasons-2020_2024.csv outputFile=workspace/col-24wk15.txt usePowerUncertainty=True |& tee tmp.txt
python forecastAndRank.py currentSeason=2024 maxRound=17 useTeamListFile=workspace/colI-list-2020_2024.csv useTeamSeasonsFile=workspace/colI-seasons-2020_2024.csv outputFile=workspace/col-24wke1.txt usePowerUncertainty=True |& tee tmp.txt
python forecastAndRank.py currentSeason=2024 maxRound=18 useTeamListFile=workspace/colI-list-2020_2024.csv useTeamSeasonsFile=workspace/colI-seasons-2020_2024.csv outputFile=workspace/col-24wke2.txt usePowerUncertainty=True |& tee tmp.txt
# also needed to add a dummy game for the following week for the final results:
python forecastAndRank.py currentSeason=2024 maxRound=19 useTeamListFile=workspace/colI-list-2020_2024.csv useTeamSeasonsFile=workspace/colI-seasons-2020_2024.csv outputFile=workspace/col-24wkfnl.txt usePowerUncertainty=True |& tee tmp.txt

makeweb.pl
update spotlight.html

scp football.html <userAndSiteWithPath>/index.html
scp football.html spotlight.html col_23earnedrank.html col_23averank.html col_23wke2result.html col_23wke3pred.html  <userAndSiteWithPath>/.
scp football.html spotlight.html col_23earnedrank.html col_23averank.html col_23wke2result.html <userAndSiteWithPath>/.

cfpool
   update cfpool.txt & findpool.pl, findpool.pl->$pred_file

