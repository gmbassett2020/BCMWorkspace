#! /usr/bin/perl -w

# Create and update the web pages for a new week of football.

use strict;
use Getopt::Long;
use File::Basename;

my ($cmd) = fileparse($0);

$| = 1; #OUTPUT_AUTOFLUSH

binmode (STDOUT);

# --- input variable initial declarations ---

#FIXME
# Note: at beginning of year, need to adjust dofindhist (only to reset the default year, does not impact this script since it provides all arguments)

my $html_base = "./html";
#my $html_base = "tmp-html";

#FIXME
my $year = "2025";
my $league = "nfl";
my $week = "week07"; # this is the current week, the result week is one less
my $today = "14 Oct 2025";
#my $year = "2023";
#my $league = "col";
#my $week = "wke3"; # this is the current week, the result week is one less, wkb#,wk##,wke#
#my $today = "18 Jan 2024";

$week =~ s/week/wk/;

# Note: for generating final results set the week to the "DELETE ME" week.

my $football_html = "$html_base/index.html";

$year =~ /(..)$/;
my $yr = $1;
my $first_week = 1;
if (($league =~ /col/ && ($week ne "wk00" && $week ne "wkb0")) || ($league =~ /nfl/ && ($week ne "wk01" && $week ne "wkb1")))
{
   $first_week = 0;
}
my $modelOutputFile = "$league-${yr}$week.txt";

#print "XXX last week $last_week\n";

my $use_nn = 0;
my $make_pred = 1;
my $make_result = 1; 
$make_result = 0 if ($first_week);
# see below where $make_pred set to 0 for last week
my $make_rank = 1;
my $make_palm = 1;
my $make_football = 1;
$make_palm = 0 if ($league eq "nfl");

my %info;
$info{col}{bfmout} = "curCol.out";
$info{col}{nnout} = "col/temout_nn";
$info{col}{league_str} = "College Football Division IA & IAA";
$info{col}{league_str_sm} = "College Football";
$info{col}{rank_str} = "NCAA Div IA & IAA";
$info{col}{league_id} = "colI";
#
my $wk_count=1;
$info{col}{2023}{wkb0}{date_str} = "Week 0 (26 Aug)";
$info{col}{2023}{wkName}{$wk_count} = "wkb0";
$info{col}{2023}{wkb0}{wk_num} = $wk_count++;
$info{col}{2023}{wkb1}{date_str} = "Week 1 (31 Aug - 4 Sep)";
$info{col}{2023}{wkName}{$wk_count} = "wkb1";
$info{col}{2023}{wkb1}{wk_num} = $wk_count++;
$info{col}{2023}{wk02}{date_str} = "Week 2 (7-10 Sep)";
$info{col}{2023}{wkName}{$wk_count} = "wk02";
$info{col}{2023}{wk02}{wk_num} = $wk_count++;
$info{col}{2023}{wk03}{date_str} = "Week 3 (14-16 Sep)";
$info{col}{2023}{wkName}{$wk_count} = "wk03";
$info{col}{2023}{wk03}{wk_num} = $wk_count++;
$info{col}{2023}{wk04}{date_str} = "Week 4 (21-24 Sep)";
$info{col}{2023}{wkName}{$wk_count} = "wk04";
$info{col}{2023}{wk04}{wk_num} = $wk_count++;
$info{col}{2023}{wk05}{date_str} = "Week 5 (28-30 Sep)";
$info{col}{2023}{wkName}{$wk_count} = "wk05";
$info{col}{2023}{wk05}{wk_num} = $wk_count++;
$info{col}{2023}{wk06}{date_str} = "Week 6 (4-7 Oct)";
$info{col}{2023}{wkName}{$wk_count} = "wk06";
$info{col}{2023}{wk06}{wk_num} = $wk_count++;
$info{col}{2023}{wk07}{date_str} = "Week 7 (10-14 Oct)";
$info{col}{2023}{wkName}{$wk_count} = "wk07";
$info{col}{2023}{wk07}{wk_num} = $wk_count++;
$info{col}{2023}{wk08}{date_str} = "Week 8 (17-21 Oct)";
$info{col}{2023}{wkName}{$wk_count} = "wk08";
$info{col}{2023}{wk08}{wk_num} = $wk_count++;
$info{col}{2023}{wk09}{date_str} = "Week 9 (24-29 Oct)";
$info{col}{2023}{wkName}{$wk_count} = "wk09";
$info{col}{2023}{wk09}{wk_num} = $wk_count++;
$info{col}{2023}{wk10}{date_str} = "Week 10 (31 Oct - 4 Nov)";
$info{col}{2023}{wkName}{$wk_count} = "wk10";
$info{col}{2023}{wk10}{wk_num} = $wk_count++;
$info{col}{2023}{wk11}{date_str} = "Week 11 (7-11 Nov)";
$info{col}{2023}{wkName}{$wk_count} = "wk11";
$info{col}{2023}{wk11}{wk_num} = $wk_count++;
$info{col}{2023}{wk12}{date_str} = "Week 12 (14-19 Nov)";
$info{col}{2023}{wkName}{$wk_count} = "wk12";
$info{col}{2023}{wk12}{wk_num} = $wk_count++;
$info{col}{2023}{wk13}{date_str} = "Week 13 (21-25 Nov)";
$info{col}{2023}{wkName}{$wk_count} = "wk13";
$info{col}{2023}{wk13}{wk_num} = $wk_count++;
$info{col}{2023}{wk14}{date_str} = "Week 14 (2 Dec)";
$info{col}{2023}{wkName}{$wk_count} = "wk14";
$info{col}{2023}{wk14}{wk_num} = $wk_count++;
$info{col}{2023}{wk15}{date_str} = "Week 15 (8-9 Dec)";
$info{col}{2023}{wkName}{$wk_count} = "wk15";
$info{col}{2023}{wk15}{wk_num} = $wk_count++;
$info{col}{2023}{wke1}{date_str} = "Bowl Games";
$info{col}{2023}{wkName}{$wk_count} = "wke1";
$info{col}{2023}{wke1}{wk_num} = $wk_count++;
$info{col}{2023}{wke2}{date_str} = "FBS & FCS Championship Games";
$info{col}{2023}{wkName}{$wk_count} = "wke2";
$info{col}{2023}{wke2}{wk_num} = $wk_count++;
$info{col}{2023}{wke3}{date_str} = "DELETE ME";
$info{col}{2023}{wkName}{$wk_count} = "wke3";
$info{col}{2023}{wke3}{wk_num} = $wk_count++;
my $wk_count=1;
$info{col}{2022}{wkb0}{date_str} = "Week 0 (27 Aug)";
$info{col}{2022}{wkName}{$wk_count} = "wkb0";
$info{col}{2022}{wkb0}{wk_num} = $wk_count++;
$info{col}{2022}{wkb1}{date_str} = "Week 1 (1-5 Sep)";
$info{col}{2022}{wkName}{$wk_count} = "wkb1";
$info{col}{2022}{wkb1}{wk_num} = $wk_count++;
$info{col}{2022}{wk02}{date_str} = "Week 2 (8-10 Sep)";
$info{col}{2022}{wkName}{$wk_count} = "wk02";
$info{col}{2022}{wk02}{wk_num} = $wk_count++;
$info{col}{2022}{wk03}{date_str} = "Week 3 (16-17 Sep)";
$info{col}{2022}{wkName}{$wk_count} = "wk03";
$info{col}{2022}{wk03}{wk_num} = $wk_count++;
$info{col}{2022}{wk04}{date_str} = "Week 4 (22-24 Sep)";
$info{col}{2022}{wkName}{$wk_count} = "wk04";
$info{col}{2022}{wk04}{wk_num} = $wk_count++;
$info{col}{2022}{wk05}{date_str} = "Week 5 (29 Sep - 1 Oct)";
$info{col}{2022}{wkName}{$wk_count} = "wk05";
$info{col}{2022}{wk05}{wk_num} = $wk_count++;
$info{col}{2022}{wk06}{date_str} = "Week 6 (7-8 Oct)";
$info{col}{2022}{wkName}{$wk_count} = "wk06";
$info{col}{2022}{wk06}{wk_num} = $wk_count++;
$info{col}{2022}{wk07}{date_str} = "Week 7 (12-16 Oct)";
$info{col}{2022}{wkName}{$wk_count} = "wk07";
$info{col}{2022}{wk07}{wk_num} = $wk_count++;
$info{col}{2022}{wk08}{date_str} = "Week 8 (19-22 Oct)";
$info{col}{2022}{wkName}{$wk_count} = "wk08";
$info{col}{2022}{wk08}{wk_num} = $wk_count++;
$info{col}{2022}{wk09}{date_str} = "Week 9 (27-29 Oct)";
$info{col}{2022}{wkName}{$wk_count} = "wk09";
$info{col}{2022}{wk09}{wk_num} = $wk_count++;
$info{col}{2022}{wk10}{date_str} = "Week 10 (1-5 Nov)";
$info{col}{2022}{wkName}{$wk_count} = "wk10";
$info{col}{2022}{wk10}{wk_num} = $wk_count++;
$info{col}{2022}{wk11}{date_str} = "Week 11 (8-12 Nov)";
$info{col}{2022}{wkName}{$wk_count} = "wk11";
$info{col}{2022}{wk11}{wk_num} = $wk_count++;
$info{col}{2022}{wk12}{date_str} = "Week 12 (15-19 Nov)";
$info{col}{2022}{wkName}{$wk_count} = "wk12";
$info{col}{2022}{wk12}{wk_num} = $wk_count++;
$info{col}{2022}{wk13}{date_str} = "Week 13 (22-26 Nov)";
$info{col}{2022}{wkName}{$wk_count} = "wk13";
$info{col}{2022}{wk13}{wk_num} = $wk_count++;
$info{col}{2022}{wk14}{date_str} = "Week 14 (2-3 Dec)";
$info{col}{2022}{wkName}{$wk_count} = "wk14";
$info{col}{2022}{wk14}{wk_num} = $wk_count++;
$info{col}{2022}{wk15}{date_str} = "Week 15 (9-10 Dec)";
$info{col}{2022}{wkName}{$wk_count} = "wk15";
$info{col}{2022}{wk15}{wk_num} = $wk_count++;
$info{col}{2022}{wke1}{date_str} = "Bowl Games";
$info{col}{2022}{wkName}{$wk_count} = "wke1";
$info{col}{2022}{wke1}{wk_num} = $wk_count++;
$info{col}{2022}{wke2}{date_str} = "FBS & FCS Championship Games";
$info{col}{2022}{wkName}{$wk_count} = "wke2";
$info{col}{2022}{wke2}{wk_num} = $wk_count++;
$info{col}{2022}{wke3}{date_str} = "DELETE ME";
$info{col}{2022}{wkName}{$wk_count} = "wke3";
$info{col}{2022}{wke3}{wk_num} = $wk_count++;
#
my $wk_count=1;
$info{col}{2021}{wkb0}{date_str} = "Week 0 (28 Aug)";
$info{col}{2021}{wkName}{$wk_count} = "wkb0";
$info{col}{2021}{wkb0}{wk_num} = $wk_count++;
$info{col}{2021}{wkb1}{date_str} = "Week 1 (1-6 Sep)";
$info{col}{2021}{wkName}{$wk_count} = "wkb1";
$info{col}{2021}{wkb1}{wk_num} = $wk_count++;
$info{col}{2021}{wk02}{date_str} = "Week 2 (10-11 Sep)";
$info{col}{2021}{wkName}{$wk_count} = "wk02";
$info{col}{2021}{wk02}{wk_num} = $wk_count++;
$info{col}{2021}{wk03}{date_str} = "Week 3 (16-19 Sep)";
$info{col}{2021}{wkName}{$wk_count} = "wk03";
$info{col}{2021}{wk03}{wk_num} = $wk_count++;
$info{col}{2021}{wk04}{date_str} = "Week 4 (23-26 Sep)";
$info{col}{2021}{wkName}{$wk_count} = "wk04";
$info{col}{2021}{wk04}{wk_num} = $wk_count++;
$info{col}{2021}{wk05}{date_str} = "Week 5 (30 Sep - 2 Oct)";
$info{col}{2021}{wkName}{$wk_count} = "wk05";
$info{col}{2021}{wk05}{wk_num} = $wk_count++;
$info{col}{2021}{wk06}{date_str} = "Week 6 (7-9 Oct)";
$info{col}{2021}{wkName}{$wk_count} = "wk06";
$info{col}{2021}{wk06}{wk_num} = $wk_count++;
$info{col}{2021}{wk07}{date_str} = "Week 7 (12-16 Oct)";
$info{col}{2021}{wkName}{$wk_count} = "wk07";
$info{col}{2021}{wk07}{wk_num} = $wk_count++;
$info{col}{2021}{wk08}{date_str} = "Week 8 (20-23 Oct)";
$info{col}{2021}{wkName}{$wk_count} = "wk08";
$info{col}{2021}{wk08}{wk_num} = $wk_count++;
$info{col}{2021}{wk09}{date_str} = "Week 9 (28-30 Oct)";
$info{col}{2021}{wkName}{$wk_count} = "wk09";
$info{col}{2021}{wk09}{wk_num} = $wk_count++;
$info{col}{2021}{wk10}{date_str} = "Week 10 (2-6 Nov)";
$info{col}{2021}{wkName}{$wk_count} = "wk10";
$info{col}{2021}{wk10}{wk_num} = $wk_count++;
$info{col}{2021}{wk11}{date_str} = "Week 11 (9-13 Nov)";
$info{col}{2021}{wkName}{$wk_count} = "wk11";
$info{col}{2021}{wk11}{wk_num} = $wk_count++;
$info{col}{2021}{wk12}{date_str} = "Week 12 (16-20 Nov)";
$info{col}{2021}{wkName}{$wk_count} = "wk12";
$info{col}{2021}{wk12}{wk_num} = $wk_count++;
$info{col}{2021}{wk13}{date_str} = "Week 13 (23-27 Nov)";
$info{col}{2021}{wkName}{$wk_count} = "wk13";
$info{col}{2021}{wk13}{wk_num} = $wk_count++;
$info{col}{2021}{wk14}{date_str} = "Week 14 (3-4 Dec)";
$info{col}{2021}{wkName}{$wk_count} = "wk14";
$info{col}{2021}{wk14}{wk_num} = $wk_count++;
$info{col}{2021}{wk15}{date_str} = "Week 15 (10-11 Dec)";
$info{col}{2021}{wkName}{$wk_count} = "wk15";
$info{col}{2021}{wk15}{wk_num} = $wk_count++;
$info{col}{2021}{wke1}{date_str} = "Bowl Games";
$info{col}{2021}{wkName}{$wk_count} = "wke1";
$info{col}{2021}{wke1}{wk_num} = $wk_count++;
$info{col}{2021}{wke2}{date_str} = "FBS & FCS Championship Games";
$info{col}{2021}{wkName}{$wk_count} = "wke2";
$info{col}{2021}{wke2}{wk_num} = $wk_count++;
$info{col}{2021}{wke3}{date_str} = "DELETE ME";
$info{col}{2021}{wkName}{$wk_count} = "wke3";
$info{col}{2021}{wke3}{wk_num} = $wk_count++;
#
my $wk_count=1;
$info{col}{2020}{wkb0}{date_str} = "Week 1 (28 Aug - 7 Sep)";
$info{col}{2020}{wkName}{$wk_count} = "wkb0";
$info{col}{2020}{wkb0}{wk_num} = $wk_count++;
$info{col}{2020}{wk02}{date_str} = "Week 2 (10-12 Sep)";
$info{col}{2020}{wkName}{$wk_count} = "wk02";
$info{col}{2020}{wk02}{wk_num} = $wk_count++;
$info{col}{2020}{wk03}{date_str} = "Week 3 (18-19 Sep)";
$info{col}{2020}{wkName}{$wk_count} = "wk03";
$info{col}{2020}{wk03}{wk_num} = $wk_count++;
$info{col}{2020}{wk04}{date_str} = "Week 4 (24-26 Sep)";
$info{col}{2020}{wkName}{$wk_count} = "wk04";
$info{col}{2020}{wk04}{wk_num} = $wk_count++;
$info{col}{2020}{wk05}{date_str} = "Week 5 (2-3 Oct)";
$info{col}{2020}{wkName}{$wk_count} = "wk05";
$info{col}{2020}{wk05}{wk_num} = $wk_count++;
$info{col}{2020}{wk06}{date_str} = "Week 6 (7-10 Oct)";
$info{col}{2020}{wkName}{$wk_count} = "wk06";
$info{col}{2020}{wk06}{wk_num} = $wk_count++;
$info{col}{2020}{wk07}{date_str} = "Week 7 (14-17 Oct)";
$info{col}{2020}{wkName}{$wk_count} = "wk07";
$info{col}{2020}{wk07}{wk_num} = $wk_count++;
$info{col}{2020}{wk08}{date_str} = "Week 8 (22-24 Oct)";
$info{col}{2020}{wkName}{$wk_count} = "wk08";
$info{col}{2020}{wk08}{wk_num} = $wk_count++;
$info{col}{2020}{wk09}{date_str} = "Week 9 (29-31 Oct)";
$info{col}{2020}{wkName}{$wk_count} = "wk09";
$info{col}{2020}{wk09}{wk_num} = $wk_count++;
$info{col}{2020}{wk10}{date_str} = "Week 10 (5-7 Nov)";
$info{col}{2020}{wkName}{$wk_count} = "wk10";
$info{col}{2020}{wk10}{wk_num} = $wk_count++;
$info{col}{2020}{wk11}{date_str} = "Week 11 (13-14 Nov)";
$info{col}{2020}{wkName}{$wk_count} = "wk11";
$info{col}{2020}{wk11}{wk_num} = $wk_count++;
$info{col}{2020}{wk12}{date_str} = "Week 12 (20-21 Nov)";
$info{col}{2020}{wkName}{$wk_count} = "wk12";
$info{col}{2020}{wk12}{wk_num} = $wk_count++;
$info{col}{2020}{wk13}{date_str} = "Week 13 (27-28 Nov)";
$info{col}{2020}{wkName}{$wk_count} = "wk13";
$info{col}{2020}{wk13}{wk_num} = $wk_count++;
$info{col}{2020}{wk14}{date_str} = "Week 14 (1-5 Dec)";
$info{col}{2020}{wkName}{$wk_count} = "wk14";
$info{col}{2020}{wk14}{wk_num} = $wk_count++;
$info{col}{2020}{wk15}{date_str} = "Week 15 (10-12 Dec)";
$info{col}{2020}{wkName}{$wk_count} = "wk15";
$info{col}{2020}{wk15}{wk_num} = $wk_count++;
$info{col}{2020}{wk16}{date_str} = "Week 16 (17-19 Dec)";
$info{col}{2020}{wkName}{$wk_count} = "wk16";
$info{col}{2020}{wk16}{wk_num} = $wk_count++;
$info{col}{2020}{wke1}{date_str} = "Bowl Games";
$info{col}{2020}{wkName}{$wk_count} = "wke1";
$info{col}{2020}{wke1}{wk_num} = $wk_count++;
$info{col}{2020}{wke2}{date_str} = "FBS & FCS Championship Games";
$info{col}{2020}{wkName}{$wk_count} = "wke2";
$info{col}{2020}{wke2}{wk_num} = $wk_count++;
$info{col}{2020}{wke3}{date_str} = "DELETE ME";
$info{col}{2020}{wkName}{$wk_count} = "wke3";
$info{col}{2020}{wke3}{wk_num} = $wk_count++;
#
my $wk_count=1;
$info{col}{2019}{wkb0}{date_str} = "Week 0 (24 Aug)";
$info{col}{2019}{wkName}{$wk_count} = "wkb0";
$info{col}{2019}{wkb0}{wk_num} = $wk_count++;
$info{col}{2019}{wkb1}{date_str} = "Week 1 (29 Aug - 2 Sep)";
$info{col}{2019}{wkName}{$wk_count} = "wkb1";
$info{col}{2019}{wkb1}{wk_num} = $wk_count++;
$info{col}{2019}{wk02}{date_str} = "Week 2 (6-7 Sep)";
$info{col}{2019}{wkName}{$wk_count} = "wk02";
$info{col}{2019}{wk02}{wk_num} = $wk_count++;
$info{col}{2019}{wk03}{date_str} = "Week 3 (13-14 Sep)";
$info{col}{2019}{wkName}{$wk_count} = "wk03";
$info{col}{2019}{wk03}{wk_num} = $wk_count++;
$info{col}{2019}{wk04}{date_str} = "Week 4 (19-21 Sep)";
$info{col}{2019}{wkName}{$wk_count} = "wk04";
$info{col}{2019}{wk04}{wk_num} = $wk_count++;
$info{col}{2019}{wk05}{date_str} = "Week 5 (26-28 Sep)";
$info{col}{2019}{wkName}{$wk_count} = "wk05";
$info{col}{2019}{wk05}{wk_num} = $wk_count++;
$info{col}{2019}{wk06}{date_str} = "Week 6 (3-5 Oct)";
$info{col}{2019}{wkName}{$wk_count} = "wk06";
$info{col}{2019}{wk06}{wk_num} = $wk_count++;
$info{col}{2019}{wk07}{date_str} = "Week 7 (9-12 Oct)";
$info{col}{2019}{wkName}{$wk_count} = "wk07";
$info{col}{2019}{wk07}{wk_num} = $wk_count++;
$info{col}{2019}{wk08}{date_str} = "Week 8 (16-19 Oct)";
$info{col}{2019}{wkName}{$wk_count} = "wk08";
$info{col}{2019}{wk08}{wk_num} = $wk_count++;
$info{col}{2019}{wk09}{date_str} = "Week 9 (24-26 Oct)";
$info{col}{2019}{wkName}{$wk_count} = "wk09";
$info{col}{2019}{wk09}{wk_num} = $wk_count++;
$info{col}{2019}{wk10}{date_str} = "Week 10 (31 Oct - 2 Nov)";
$info{col}{2019}{wkName}{$wk_count} = "wk10";
$info{col}{2019}{wk10}{wk_num} = $wk_count++;
$info{col}{2019}{wk11}{date_str} = "Week 11 (5-9 Nov)";
$info{col}{2019}{wkName}{$wk_count} = "wk11";
$info{col}{2019}{wk11}{wk_num} = $wk_count++;
$info{col}{2019}{wk12}{date_str} = "Week 12 (12-16 Nov)";
$info{col}{2019}{wkName}{$wk_count} = "wk12";
$info{col}{2019}{wk12}{wk_num} = $wk_count++;
$info{col}{2019}{wk13}{date_str} = "Week 13 (19-23 Nov)";
$info{col}{2019}{wkName}{$wk_count} = "wk13";
$info{col}{2019}{wk13}{wk_num} = $wk_count++;
$info{col}{2019}{wk14}{date_str} = "Week 14 (26-30 Nov)";
$info{col}{2019}{wkName}{$wk_count} = "wk14";
$info{col}{2019}{wk14}{wk_num} = $wk_count++;
$info{col}{2019}{wk15}{date_str} = "Week 15 (6-7 Dec)";
$info{col}{2019}{wkName}{$wk_count} = "wk15";
$info{col}{2019}{wk15}{wk_num} = $wk_count++;
$info{col}{2019}{wk16}{date_str} = "Week 16 (13-14 Dec)";
$info{col}{2019}{wkName}{$wk_count} = "wk16";
$info{col}{2019}{wk16}{wk_num} = $wk_count++;
$info{col}{2019}{wke1}{date_str} = "Bowl Games";
$info{col}{2019}{wkName}{$wk_count} = "wke1";
$info{col}{2019}{wke1}{wk_num} = $wk_count++;
$info{col}{2019}{wke2}{date_str} = "FBS & FCS Championship Games";
$info{col}{2019}{wkName}{$wk_count} = "wke2";
$info{col}{2019}{wke2}{wk_num} = $wk_count++;
$info{col}{2019}{wke3}{date_str} = "DELETE ME";
$info{col}{2019}{wkName}{$wk_count} = "wke3";
$info{col}{2019}{wke3}{wk_num} = $wk_count++;
#
$wk_count=1;
$info{col}{2018}{wkb0}{date_str} = "Week 0 (25 Aug)";
$info{col}{2018}{wkName}{$wk_count} = "wkb0";
$info{col}{2018}{wkb0}{wk_num} = $wk_count++;
$info{col}{2018}{wkb1}{date_str} = "Week 1 (30 Aug - 3 Sep)";
$info{col}{2018}{wkName}{$wk_count} = "wkb1";
$info{col}{2018}{wkb1}{wk_num} = $wk_count++;
$info{col}{2018}{wk02}{date_str} = "Week 2 (6-8 Sep)";
$info{col}{2018}{wkName}{$wk_count} = "wk02";
$info{col}{2018}{wk02}{wk_num} = $wk_count++;
$info{col}{2018}{wk03}{date_str} = "Week 3 (13-15 Sep)";
$info{col}{2018}{wkName}{$wk_count} = "wk03";
$info{col}{2018}{wk03}{wk_num} = $wk_count++;
$info{col}{2018}{wk04}{date_str} = "Week 4 (20-22 Sep)";
$info{col}{2018}{wkName}{$wk_count} = "wk04";
$info{col}{2018}{wk04}{wk_num} = $wk_count++;
$info{col}{2018}{wk05}{date_str} = "Week 5 (27-29 Sep)";
$info{col}{2018}{wkName}{$wk_count} = "wk05";
$info{col}{2018}{wk05}{wk_num} = $wk_count++;
$info{col}{2018}{wk06}{date_str} = "Week 6 (4-6 Oct)";
$info{col}{2018}{wkName}{$wk_count} = "wk06";
$info{col}{2018}{wk06}{wk_num} = $wk_count++;
$info{col}{2018}{wk07}{date_str} = "Week 7 (9-13 Oct)";
$info{col}{2018}{wkName}{$wk_count} = "wk07";
$info{col}{2018}{wk07}{wk_num} = $wk_count++;
$info{col}{2018}{wk08}{date_str} = "Week 8 (18-20 Oct)";
$info{col}{2018}{wkName}{$wk_count} = "wk08";
$info{col}{2018}{wk08}{wk_num} = $wk_count++;
$info{col}{2018}{wk09}{date_str} = "Week 9 (23-27 Oct)";
$info{col}{2018}{wkName}{$wk_count} = "wk09";
$info{col}{2018}{wk09}{wk_num} = $wk_count++;
$info{col}{2018}{wk10}{date_str} = "Week 10 (30 Oct - 3 Nov)";
$info{col}{2018}{wkName}{$wk_count} = "wk10";
$info{col}{2018}{wk10}{wk_num} = $wk_count++;
$info{col}{2018}{wk11}{date_str} = "Week 11 (6-10 Nov)";
$info{col}{2018}{wkName}{$wk_count} = "wk11";
$info{col}{2018}{wk11}{wk_num} = $wk_count++;
$info{col}{2018}{wk12}{date_str} = "Week 12 (13-17 Nov)";
$info{col}{2018}{wkName}{$wk_count} = "wk12";
$info{col}{2018}{wk12}{wk_num} = $wk_count++;
$info{col}{2018}{wk13}{date_str} = "Week 13 (20-24 Nov)";
$info{col}{2018}{wkName}{$wk_count} = "wk13";
$info{col}{2018}{wk13}{wk_num} = $wk_count++;
$info{col}{2018}{wk14}{date_str} = "Week 14 (30 Nov - 1 Dec)";
$info{col}{2018}{wkName}{$wk_count} = "wk14";
$info{col}{2018}{wk14}{wk_num} = $wk_count++;
$info{col}{2018}{wk15}{date_str} = "Week 15 (8 Dec)";
$info{col}{2018}{wkName}{$wk_count} = "wk15";
$info{col}{2018}{wk15}{wk_num} = $wk_count++;
$info{col}{2018}{wke1}{date_str} = "Bowl Games";
$info{col}{2018}{wkName}{$wk_count} = "wke1";
$info{col}{2018}{wke1}{wk_num} = $wk_count++;
$info{col}{2018}{wke2}{date_str} = "FBS & FCS Championship Games";
$info{col}{2018}{wkName}{$wk_count} = "wke2";
$info{col}{2018}{wke2}{wk_num} = $wk_count++;
$info{col}{2018}{wke3}{date_str} = "DELETE ME";
$info{col}{2018}{wkName}{$wk_count} = "wke3";
$info{col}{2018}{wke3}{wk_num} = $wk_count++;
#
$info{col}{2017}{wk00}{date_str} = "Week 0 (26-27 Aug)";
$info{col}{2017}{wk01}{date_str} = "Week 1 (31 Aug - 4 Sep)";
$info{col}{2017}{wk02}{date_str} = "Week 2 (7-9 Sep)";
$info{col}{2017}{wk03}{date_str} = "Week 3 (14-16 Sep)";
$info{col}{2017}{wk04}{date_str} = "Week 4 (21-23 Sep)";
$info{col}{2017}{wk05}{date_str} = "Week 5 (28-30 Sep)";
$info{col}{2017}{wk06}{date_str} = "Week 6 (4-7 Oct)";
$info{col}{2017}{wk07}{date_str} = "Week 7 (11-14 Oct)";
$info{col}{2017}{wk08}{date_str} = "Week 8 (19-21 Oct)";
$info{col}{2017}{wk09}{date_str} = "Week 9 (26-28 Oct)";
$info{col}{2017}{wk10}{date_str} = "Week 10 (31 Oct - 4 Nov)";
$info{col}{2017}{wk11}{date_str} = "Week 11 (7-11 Nov)";
$info{col}{2017}{wk12}{date_str} = "Week 12 (14-18 Nov)";
$info{col}{2017}{wk13}{date_str} = "Week 13 (21-25 Nov)";
$info{col}{2017}{wk14}{date_str} = "Week 14 (1-2 Dec)";
$info{col}{2017}{wk15}{date_str} = "Week 15 (8-9 Dec)";
$info{col}{2017}{wk16}{date_str} = "Bowl Games";
$info{col}{2017}{wk17}{date_str} = "FBS & FCS Championship Games";
$info{col}{2017}{wk18}{date_str} = "DELETE ME";
#
$info{col}{2016}{wk01}{date_str} = "Week 1 (27 Aug)";
$info{col}{2016}{wk02}{date_str} = "Week 2 (1-5 Sep)";
$info{col}{2016}{wk03}{date_str} = "Week 3 (8-10 Sep)";
$info{col}{2016}{wk04}{date_str} = "Week 4 (15-17 Sep)";
$info{col}{2016}{wk05}{date_str} = "Week 5 (22-24 Sep)";
$info{col}{2016}{wk06}{date_str} = "Week 6 (29 Sep - 1 Oct)";
$info{col}{2016}{wk07}{date_str} = "Week 7 (5-08 Oct)";
$info{col}{2016}{wk08}{date_str} = "Week 8 (12-15 Oct)";
$info{col}{2016}{wk09}{date_str} = "Week 9 (20-22 Oct)";
$info{col}{2016}{wk10}{date_str} = "Week 10 (27-29 Oct)";
$info{col}{2016}{wk11}{date_str} = "Week 11 (1-5 Nov)";
$info{col}{2016}{wk12}{date_str} = "Week 12 (8-12 Nov)";
$info{col}{2016}{wk13}{date_str} = "Week 13 (15-19 Nov)";
$info{col}{2016}{wk14}{date_str} = "Week 14 (22-26 Nov)";
$info{col}{2016}{wk15}{date_str} = "Week 15 (2-3 Dec)";
$info{col}{2016}{wk16}{date_str} = "Week 16 (9-10 Dec)";
$info{col}{2016}{wk17}{date_str} = "Bowl Games";
$info{col}{2016}{wk18}{date_str} = "FBS & FCS Championship Games";
$info{col}{2016}{wk19}{date_str} = "DELETE ME";
#
#
$info{col}{2015}{wk01}{date_str} = "Week 1 (29 Aug)";
$info{col}{2015}{wk02}{date_str} = "Week 2 (3-7 Sep)";
$info{col}{2015}{wk03}{date_str} = "Week 3 (10-12 Sep)";
$info{col}{2015}{wk04}{date_str} = "Week 4 (17-19 Sep)";
$info{col}{2015}{wk05}{date_str} = "Week 5 (24-26 Sep)";
$info{col}{2015}{wk06}{date_str} = "Week 6 (1-3 Oct)";
$info{col}{2015}{wk07}{date_str} = "Week 7 (8-10 Oct)";
$info{col}{2015}{wk08}{date_str} = "Week 8 (13-17 Oct)";
$info{col}{2015}{wk09}{date_str} = "Week 9 (20-24 Oct)";
$info{col}{2015}{wk10}{date_str} = "Week 10 (29-31 Oct)";
$info{col}{2015}{wk11}{date_str} = "Week 11 (3-7 Nov)";
$info{col}{2015}{wk12}{date_str} = "Week 12 (10-14 Nov)";
$info{col}{2015}{wk13}{date_str} = "Week 13 (17-21 Nov)";
$info{col}{2015}{wk14}{date_str} = "Week 14 (24-28 Nov)";
$info{col}{2015}{wk15}{date_str} = "Week 15 (4-5 Dec)";
$info{col}{2015}{wk16}{date_str} = "Week 16 (11-12 Dec)";
$info{col}{2015}{wk17}{date_str} = "Bowl Games";
$info{col}{2015}{wk18}{date_str} = "FBS & FCS Championship Games (9 & 12 Jan)";
$info{col}{2015}{wk19}{date_str} = "DELETE ME";
#
$info{col}{2014}{wk01}{date_str} = "Week 1 (23 Aug)";
$info{col}{2014}{wk02}{date_str} = "Week 2 (27-31 Aug)";
$info{col}{2014}{wk03}{date_str} = "Week 3 (1-6 Sep)";
$info{col}{2014}{wk04}{date_str} = "Week 4 (11-13 Sep)";
$info{col}{2014}{wk05}{date_str} = "Week 5 (18-20 Sep)";
$info{col}{2014}{wk06}{date_str} = "Week 6 (25-27 Sep)";
$info{col}{2014}{wk07}{date_str} = "Week 7 (2-4 Oct)";
$info{col}{2014}{wk08}{date_str} = "Week 8 (9-11 Oct)";
$info{col}{2014}{wk09}{date_str} = "Week 9 (14-18 Oct)";
$info{col}{2014}{wk10}{date_str} = "Week 10 (21-25 Oct)";
$info{col}{2014}{wk11}{date_str} = "Week 11 (30 Oct - 1 Nov)";
$info{col}{2014}{wk12}{date_str} = "Week 12 (4-8 Nov)";
$info{col}{2014}{wk13}{date_str} = "Week 13 (11-15 Nov)";
$info{col}{2014}{wk14}{date_str} = "Week 14 (18-22 Nov)";
$info{col}{2014}{wk15}{date_str} = "Week 15 (25-29 Nov)";
$info{col}{2014}{wk16}{date_str} = "Week 16 (4-6 Dec)";
$info{col}{2014}{wk17}{date_str} = "Week 17 (13 Dec) + preliminary bowl games";
$info{col}{2014}{wk18}{date_str} = "Bowl Games";
$info{col}{2014}{wk19}{date_str} = "FBS & FCS Championship Games (10-12 Jan)";
$info{col}{2014}{wk20}{date_str} = "DELETE ME";
#
$info{col}{2013}{wk01}{date_str} = "Week 1 (29 Aug - 2 Sep)";
$info{col}{2013}{wk02}{date_str} = "Week 2 (5-7 Sep)";
$info{col}{2013}{wk03}{date_str} = "Week 3 (12-14 Sep)";
$info{col}{2013}{wk04}{date_str} = "Week 4 (19-21 Sep)";
$info{col}{2013}{wk05}{date_str} = "Week 5 (26-28 Sep)";
$info{col}{2013}{wk06}{date_str} = "Week 6 (3-5 Oct)";
$info{col}{2013}{wk07}{date_str} = "Week 7 (10-12 Oct)";
$info{col}{2013}{wk08}{date_str} = "Week 8 (15-19 Oct)";
$info{col}{2013}{wk09}{date_str} = "Week 9 (22-26 Oct)";
$info{col}{2013}{wk10}{date_str} = "Week 10 (30 Oct - 2 Nov)";
$info{col}{2013}{wk11}{date_str} = "Week 11 (5-9 Nov)";
$info{col}{2013}{wk12}{date_str} = "Week 12 (12-16 Nov)";
$info{col}{2013}{wk13}{date_str} = "Week 13 (19-23 Nov)";
$info{col}{2013}{wk14}{date_str} = "Week 14 (26-30 Nov)";
$info{col}{2013}{wk15}{date_str} = "Week 15 (5-7 Dec)";
$info{col}{2013}{wk16}{date_str} = "Week 16 (14 Dec) + preliminary bowl games";
$info{col}{2013}{wk17}{date_str} = "Bowl Games";
$info{col}{2013}{wk18}{date_str} = "DELETE ME";
#
$info{col}{2012}{wk01}{date_str} = "Week 1 (30 Aug - 3 Sep)";
$info{col}{2012}{wk02}{date_str} = "Week 2 (3-8 Sep)";
$info{col}{2012}{wk03}{date_str} = "Week 3 (13-15 Sep)";
$info{col}{2012}{wk04}{date_str} = "Week 4 (19-22 Sep)";
$info{col}{2012}{wk05}{date_str} = "Week 5 (27-29 Sep)";
$info{col}{2012}{wk06}{date_str} = "Week 6 (4-6 Oct)";
$info{col}{2012}{wk07}{date_str} = "Week 7 (11-13 Oct)";
$info{col}{2012}{wk08}{date_str} = "Week 8 (16-19 Oct)";
$info{col}{2012}{wk09}{date_str} = "Week 9 (23-27 Oct)";
$info{col}{2012}{wk10}{date_str} = "Week 10 (1-3 Nov)";
$info{col}{2012}{wk11}{date_str} = "Week 11 (6-10 Nov)";
$info{col}{2012}{wk12}{date_str} = "Week 12 (14-17 Nov)";
$info{col}{2012}{wk13}{date_str} = "Week 13 (20-24 Nov)";
$info{col}{2012}{wk14}{date_str} = "Week 14 (29 Nov - 1 Dec)";
$info{col}{2012}{wk15}{date_str} = "Week 15 (8 Dec) + preliminary bowl games";
$info{col}{2012}{wk16}{date_str} = "Bowl Games";
$info{col}{2012}{wk17}{date_str} = "DELETE ME";
#
#
$info{col}{2011}{wk01}{date_str} = "Week 1 (1-5 Sep)";
$info{col}{2011}{wk02}{date_str} = "Week 2 (8-10 Sep)";
$info{col}{2011}{wk03}{date_str} = "Week 3 (15-17 Sep)";
$info{col}{2011}{wk04}{date_str} = "Week 4 (22-24 Sep)";
$info{col}{2011}{wk05}{date_str} = "Week 5 (29 Sep - 1 Oct)";
$info{col}{2011}{wk06}{date_str} = "Week 6 (6-8 Oct)";
$info{col}{2011}{wk07}{date_str} = "Week 7 (13-15 Oct)";
$info{col}{2011}{wk08}{date_str} = "Week 8 (18-22 Oct)";
$info{col}{2011}{wk09}{date_str} = "Week 9 (25-29 Oct)";
$info{col}{2011}{wk10}{date_str} = "Week 10 (1-5 Nov)";
$info{col}{2011}{wk11}{date_str} = "Week 11 (8-12 Nov)";
$info{col}{2011}{wk12}{date_str} = "Week 12 (15-19 Nov)";
$info{col}{2011}{wk13}{date_str} = "Week 13 (22-26 Nov)";
$info{col}{2011}{wk14}{date_str} = "Week 14 (1-3 Dec)";
$info{col}{2011}{wk15}{date_str} = "Week 15 (10 Dec)";
$info{col}{2011}{wk16}{date_str} = "Bowl Games";
$info{col}{2011}{wk17}{date_str} = "DELETE ME";
#
#
$info{col}{2010}{wk01}{date_str} = "Week 1 (2-6 Sep)";
$info{col}{2010}{wk02}{date_str} = "Week 2 (9-11 Sep)";
$info{col}{2010}{wk03}{date_str} = "Week 3 (16-18 Sep)";
$info{col}{2010}{wk04}{date_str} = "Week 4 (23-25 Sep)";
$info{col}{2010}{wk05}{date_str} = "Week 5 (30 Sep - 2 Oct)";
$info{col}{2010}{wk06}{date_str} = "Week 6 (5-9 Oct)";
$info{col}{2010}{wk07}{date_str} = "Week 7 (13-16 Oct)";
$info{col}{2010}{wk08}{date_str} = "Week 8 (21-23 Oct)";
$info{col}{2010}{wk09}{date_str} = "Week 9 (26-30 Oct)";
$info{col}{2010}{wk10}{date_str} = "Week 10 (2-6 Nov)";
$info{col}{2010}{wk11}{date_str} = "Week 11 (9-13 Nov)";
$info{col}{2010}{wk12}{date_str} = "Week 12 (16-20 Nov)";
$info{col}{2010}{wk13}{date_str} = "Week 13 (23-27 Nov)";
$info{col}{2010}{wk14}{date_str} = "Week 14 (2-4 Dec)";
$info{col}{2010}{wk15}{date_str} = "Week 15 (11 Dec)";
$info{col}{2010}{wk16}{date_str} = "Bowl Games";
$info{col}{2010}{wk17}{date_str} = "DELETE ME";
#
$info{col}{2009}{wk01}{date_str} = "Week 1 (3-7 Sep)";
$info{col}{2009}{wk02}{date_str} = "Week 2 (10-12 Sep)";
$info{col}{2009}{wk03}{date_str} = "Week 3 (17-19 Sep)";
$info{col}{2009}{wk04}{date_str} = "Week 4 (24-26 Sep)";
$info{col}{2009}{wk05}{date_str} = "Week 5 (30 Sep - 3 Oct)";
$info{col}{2009}{wk06}{date_str} = "Week 6 (6-10 Oct)";
$info{col}{2009}{wk07}{date_str} = "Week 7 (13-17 Oct)";
$info{col}{2009}{wk08}{date_str} = "Week 8 (21-24 Oct)";
$info{col}{2009}{wk09}{date_str} = "Week 9 (27 Oct - 1 Nov)";
$info{col}{2009}{wk10}{date_str} = "Week 10 (3-8 Nov)";
$info{col}{2009}{wk11}{date_str} = "Week 11 (10-15 Nov)";
$info{col}{2009}{wk12}{date_str} = "Week 12 (18-21 Nov)";
$info{col}{2009}{wk13}{date_str} = "Week 13 (24-28 Nov)";
$info{col}{2009}{wk14}{date_str} = "Week 14 (3-5 Dec)";
$info{col}{2009}{wk15}{date_str} = "Week 15 (12 Dec) + preliminary bowl games";
$info{col}{2009}{wk16}{date_str} = "Bowl Games";
$info{col}{2009}{wk17}{date_str} = "DELETE ME";
#
$info{col}{2008}{wk01}{date_str} = "Week 1 (28 Aug - 1 Sep)";
$info{col}{2008}{wk02}{date_str} = "Week 2 (4-6 Sep)";
$info{col}{2008}{wk03}{date_str} = "Week 3 (11-13 Sep)";
$info{col}{2008}{wk04}{date_str} = "Week 4 (17-20 Sep)";
$info{col}{2008}{wk05}{date_str} = "Week 5 (25-27 Sep)";
$info{col}{2008}{wk06}{date_str} = "Week 6 (30 Sep - 4 Oct)";
$info{col}{2008}{wk07}{date_str} = "Week 7 (7-11 Oct)";
$info{col}{2008}{wk08}{date_str} = "Week 8 (16-18 Oct)";
$info{col}{2008}{wk09}{date_str} = "Week 9 (21-26 Oct)";
$info{col}{2008}{wk10}{date_str} = "Week 10 (28 Oct - 2 Nov)";
$info{col}{2008}{wk11}{date_str} = "Week 11 (4-8 Nov)";
$info{col}{2008}{wk12}{date_str} = "Week 12 (11-15 Nov)";
$info{col}{2008}{wk13}{date_str} = "Week 13 (18-23 Nov)";
$info{col}{2008}{wk14}{date_str} = "Week 14 (25-29 Nov)";
$info{col}{2008}{wk15}{date_str} = "Week 15 (3-6 Dec)";
$info{col}{2008}{wk16}{date_str} = "Week 16 (12-13 Dec) + preliminary bowl games";
$info{col}{2008}{wk17}{date_str} = "Bowl Games";
$info{col}{2008}{wk18}{date_str} = "DELETE ME";
#
$info{col}{2007}{wk01}{date_str} = "Week 1 (30 Aug - 1 Sep)";
$info{col}{2007}{wk02}{date_str} = "Week 2 (3-8 Sep)";
$info{col}{2007}{wk03}{date_str} = "Week 3 (13-15 Sep)";
$info{col}{2007}{wk04}{date_str} = "Week 4 (20-22 Sep)";
$info{col}{2007}{wk05}{date_str} = "Week 5 (27-29 Sep)";
$info{col}{2007}{wk06}{date_str} = "Week 6 (2-7 Oct)";
$info{col}{2007}{wk07}{date_str} = "Week 7 (10-14 Oct)";
$info{col}{2007}{wk08}{date_str} = "Week 8 (18-21 Oct)";
$info{col}{2007}{wk09}{date_str} = "Week 9 (25-28 Oct)";
$info{col}{2007}{wk10}{date_str} = "Week 10 (1-4 Nov)";
$info{col}{2007}{wk11}{date_str} = "Week 11 (6-10 Nov)";
$info{col}{2007}{wk12}{date_str} = "Week 12 (13-17 Nov)";
$info{col}{2007}{wk13}{date_str} = "Week 13 (20-24 Nov)";
$info{col}{2007}{wk14}{date_str} = "Week 14 (29 Nov - 1 Dec)";
$info{col}{2007}{wk15}{date_str} = "Week 15 (7-8 Dec) + preliminary bowl games";
$info{col}{2007}{wk16}{date_str} = "Bowl Games";
$info{col}{2007}{wk17}{date_str} = "DELETE ME";
#
$info{col}{2006}{wk01}{date_str} = "Week 1 (31 Aug - 4 Sep)";
$info{col}{2006}{wk02}{date_str} = "Week 2 (7-9 Sep)";
$info{col}{2006}{wk03}{date_str} = "Week 3 (14-16 Sep)";
$info{col}{2006}{wk04}{date_str} = "Week 4 (21-23 Sep)";
$info{col}{2006}{wk05}{date_str} = "Week 5 (26-30 Sep)";
$info{col}{2006}{wk06}{date_str} = "Week 6 (3-8 Oct)";
$info{col}{2006}{wk07}{date_str} = "Week 7 (12-15 Oct)";
$info{col}{2006}{wk08}{date_str} = "Week 8 (18-22 Oct)";
$info{col}{2006}{wk09}{date_str} = "Week 9 (26-29 Oct)";
$info{col}{2006}{wk10}{date_str} = "Week 10 (31 Oct - 5 Nov)";
$info{col}{2006}{wk11}{date_str} = "Week 11 (7-12 Nov)";
$info{col}{2006}{wk12}{date_str} = "Week 12 (14-18 Nov)";
$info{col}{2006}{wk13}{date_str} = "Week 13 (21-25 Nov)";
$info{col}{2006}{wk14}{date_str} = "Week 14 (30 Nov - 2 Dec)";
$info{col}{2006}{wk15}{date_str} = "Week 15 (8-9 Dec) + preliminary bowl games";
$info{col}{2006}{wk16}{date_str} = "Bowl Games";
$info{col}{2006}{wk17}{date_str} = "DELETE ME";
#
$info{col}{2005}{wk01}{date_str} = "Week 1 (1-5 Sep)";
$info{col}{2005}{wk02}{date_str} = "Week 2 (8-10 Sep)";
$info{col}{2005}{wk03}{date_str} = "Week 3 (15-17 Sep)";
$info{col}{2005}{wk04}{date_str} = "Week 4 (21-24 Sep)";
$info{col}{2005}{wk05}{date_str} = "Week 5 (27 Sep - 1 Oct)";
$info{col}{2005}{wk06}{date_str} = "Week 6 (4-8 Oct)";
$info{col}{2005}{wk07}{date_str} = "Week 7 (13-15 Oct)";
$info{col}{2005}{wk08}{date_str} = "Week 8 (20-22 Oct)";
$info{col}{2005}{wk09}{date_str} = "Week 9 (27-29 Oct)";
$info{col}{2005}{wk10}{date_str} = "Week 10 (1-5 Nov)";
$info{col}{2005}{wk11}{date_str} = "Week 11 (8-13 Nov)";
$info{col}{2005}{wk12}{date_str} = "Week 12 (15-19 Nov)";
$info{col}{2005}{wk13}{date_str} = "Week 13 (21-26 Nov)";
$info{col}{2005}{wk14}{date_str} = "Week 14 (2-3 Dec)";
$info{col}{2005}{wk15}{date_str} = "Week 15 (9-10 Dec)";
$info{col}{2005}{wk16}{date_str} = "Bowl Games";
$info{col}{2005}{wk17}{date_str} = "DELETE ME";
#
$info{col}{2004}{wk00}{date_str} = "Preseason (28 Aug)";
$info{col}{2004}{wk01}{date_str} = "Week 1 (2-6 Sep)";
$info{col}{2004}{wk02}{date_str} = "Week 2 (9-11 Sep)";
$info{col}{2004}{wk03}{date_str} = "Week 3 (16-18 Sep)";
$info{col}{2004}{wk04}{date_str} = "Week 4 (23-25 Sep)";
$info{col}{2004}{wk05}{date_str} = "Week 5 (29 Sep - 2 Oct)";
$info{col}{2004}{wk06}{date_str} = "Week 6 (7-9 Oct)";
$info{col}{2004}{wk07}{date_str} = "Week 7 (13-16 Oct)";
$info{col}{2004}{wk08}{date_str} = "Week 8 (21-23 Oct)";
$info{col}{2004}{wk09}{date_str} = "Week 9 (28-30 Oct)";
$info{col}{2004}{wk10}{date_str} = "Week 10 (3-6 Nov)";
$info{col}{2004}{wk11}{date_str} = "Week 11 (9-13 Nov)";
$info{col}{2004}{wk12}{date_str} = "Week 12 (18-20 Nov)";
$info{col}{2004}{wk13}{date_str} = "Week 13 (23-27 Nov)";
$info{col}{2004}{wk14}{date_str} = "Week 14 (2-4 Dec)";
$info{col}{2004}{wk15}{date_str} = "Week 15 (10-11 Dec)";
$info{col}{2004}{wk16}{date_str} = "Bowl Games";
$info{col}{2004}{wk17}{date_str} = "DELETE ME";
#
$info{col}{2003}{wk00}{date_str} = "Preseason (23 Aug)";
$info{col}{2003}{wk01}{date_str} = "Week 1 (28 Aug - 1 Sep)";
$info{col}{2003}{wk02}{date_str} = "Week 2 (4-6 Sep)";
$info{col}{2003}{wk03}{date_str} = "Week 3 (11-13 Sep)";
$info{col}{2003}{wk04}{date_str} = "Week 4 (18-20 Sep)";
$info{col}{2003}{wk05}{date_str} = "Week 5 (25-27 Sep)";
$info{col}{2003}{wk06}{date_str} = "Week 6 (30 Sep - 4 Oct)";
$info{col}{2003}{wk07}{date_str} = "Week 7 (9-11 Oct)";
$info{col}{2003}{wk08}{date_str} = "Week 8 (16-18 Oct)";
$info{col}{2003}{wk09}{date_str} = "Week 9 (22-25 Oct)";
$info{col}{2003}{wk10}{date_str} = "Week 10 (30 Oct - 1 Nov)";
$info{col}{2003}{wk11}{date_str} = "Week 11 (4-8 Nov)";
$info{col}{2003}{wk12}{date_str} = "Week 12 (12-15 Nov)";
$info{col}{2003}{wk13}{date_str} = "Week 13 (19-22 Nov)";
$info{col}{2003}{wk14}{date_str} = "Week 14 (25-29 Nov)";
$info{col}{2003}{wk15}{date_str} = "Week 15 (4-6 Dec)";
$info{col}{2003}{wk16}{date_str} = "Week 16 (13 Dec)";
$info{col}{2003}{wk17}{date_str} = "Bowl Games";
$info{col}{2003}{wk18}{date_str} = "DELETE ME";
#
$info{col}{2002}{wk00}{date_str} = "Preseason (22-24 Aug)";
$info{col}{2002}{wk01}{date_str} = "Week 1 (29 Aug - 2 Sep)";
$info{col}{2002}{wk02}{date_str} = "Week 2 (5-7 Sep)";
$info{col}{2002}{wk03}{date_str} = "Week 3 (12-14 Sep)";
$info{col}{2002}{wk04}{date_str} = "Week 4 (19-21 Sep)";
$info{col}{2002}{wk05}{date_str} = "Week 5 (26-28 Sep)";
$info{col}{2002}{wk06}{date_str} = "Week 6 (3-5 Oct)";
$info{col}{2002}{wk07}{date_str} = "Week 7 (8-12 Oct)";
$info{col}{2002}{wk08}{date_str} = "Week 8 (16-19 Oct)";
$info{col}{2002}{wk09}{date_str} = "Week 9 (24-26 Oct)";
$info{col}{2002}{wk10}{date_str} = "Week 10 (29 Oct - 2 Nov)";
$info{col}{2002}{wk11}{date_str} = "Week 11 (9 Nov)";
$info{col}{2002}{wk12}{date_str} = "Week 12 (12-16 Nov)";
$info{col}{2002}{wk13}{date_str} = "Week 13 (20-23 Nov)";
$info{col}{2002}{wk14}{date_str} = "Week 14 (28-30 Nov)";
$info{col}{2002}{wk15}{date_str} = "Week 15 (2-7 Dec)";
$info{col}{2002}{wk16}{date_str} = "Week 16 (14 Dec)";
$info{col}{2002}{wk17}{date_str} = "Bowl Games";
$info{col}{2002}{wk18}{date_str} = "DELETE ME";
#
$info{col}{2001}{wk05}{date_str} = "Week 5 (27-30 Sep)";
$info{col}{2001}{wk06}{date_str} = "Week 6 (4-7 Oct)";
$info{col}{2001}{wk07}{date_str} = "Week 7 (11-13 Oct)";
$info{col}{2001}{wk08}{date_str} = "Week 8 (16-20 Oct)";
$info{col}{2001}{wk09}{date_str} = "Week 9 (25-27 Oct)";
$info{col}{2001}{wk10}{date_str} = "Week 10 (30 Oct - 3 Nov)";
$info{col}{2001}{wk11}{date_str} = "Week 11 (6-10 Nov)";
$info{col}{2001}{wk12}{date_str} = "Week 12 (15-17 Nov)";
$info{col}{2001}{wk13}{date_str} = "Week 13 (21-24 Nov)";
$info{col}{2001}{wk14}{date_str} = "Week 14 (29 Nov - 1 Dec)";
$info{col}{2001}{wk15}{date_str} = "Week 15 (7-8 Dec)";
$info{col}{2001}{wk16}{date_str} = "Week 16 (15 Dec)";
$info{col}{2001}{wk17}{date_str} = "Bowl Games";
$info{col}{2001}{wk18}{date_str} = "DELETE ME";

$info{nfl}{bfmout} = "curNfl.out";
$info{nfl}{nnout} = "nfl/temout_nn";
$info{nfl}{league_str} = "the National Football League";
$info{nfl}{league_str_sm} = "NFL";
$info{nfl}{rank_str} = "NFL";
$info{nfl}{league_id} = "nfl";

sub addWeek
{
   my ($league, $season, $weekName, $weekDescription, $weekCount) = @_;
   $info{$league}{$season}{$weekName}{date_str} = $weekDescription;
   $info{$league}{$season}{wkName}{$weekCount} = "$weekName";
   $info{$league}{$season}{$weekName}{wk_num} = $weekCount;
   print "::: added info for league=$league season=$season weekName=$weekName weekDescription=$info{$league}{$season}{$weekName}{date_str} weekNum=$info{$league}{$season}{$weekName}{wk_num}\n";
}

# NFL dates

# 2025 season:
my $yearInfo = 2025;
$wk_count = 1;
addWeek($league, $yearInfo, "wkb1", "Week 1 (4-8 Sep)", $wk_count++);
addWeek($league, $yearInfo, "wk02", "Week 2 (11-15 Sep)", $wk_count++);
addWeek($league, $yearInfo, "wk03", "Week 3 (18-22 Sep)", $wk_count++);
addWeek($league, $yearInfo, "wk04", "Week 4 (25-29 Sep)", $wk_count++);
addWeek($league, $yearInfo, "wk05", "Week 5 (2-6 Oct)", $wk_count++);
addWeek($league, $yearInfo, "wk06", "Week 6 (9-13 Oct)", $wk_count++);
addWeek($league, $yearInfo, "wk07", "Week 7 (16-20 Oct)", $wk_count++);
addWeek($league, $yearInfo, "wk08", "Week 8 (23-27 Oct)", $wk_count++);
addWeek($league, $yearInfo, "wk09", "Week 9 (30 Oct - 3 Nov)", $wk_count++);
addWeek($league, $yearInfo, "wk10", "Week 10 (6-10 Nov)", $wk_count++);
addWeek($league, $yearInfo, "wk11", "Week 11 (13-17 Nov)", $wk_count++);
addWeek($league, $yearInfo, "wk12", "Week 12 (20-24 Nov)", $wk_count++);
addWeek($league, $yearInfo, "wk13", "Week 13 (27 Nov - 1 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk14", "Week 14 (4-8 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk15", "Week 15 (11-15 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk16", "Week 16 (18-22 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk17", "Week 17 (25-29 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk18", "Week 18 (4 Jan)", $wk_count++);
addWeek($league, $yearInfo, "wke1", "Postseason: Wild Card (10-12 Jan)", $wk_count++);
addWeek($league, $yearInfo, "wke2", "Postseason: Divisional (17-18 Jan)", $wk_count++);
addWeek($league, $yearInfo, "wke3", "Postseason: Conference (25 Jan)", $wk_count++);
addWeek($league, $yearInfo, "wke4", "Super Bowl (8 Feb)", $wk_count++);


# 2024 season:
my $yearInfo = 2024;
$wk_count = 1;
addWeek($league, $yearInfo, "wkb1", "Week 1 (5-9 Sep)", $wk_count++);
addWeek($league, $yearInfo, "wk02", "Week 2 (12-16 Sep)", $wk_count++);
addWeek($league, $yearInfo, "wk03", "Week 3 (19-23 Sep)", $wk_count++);
addWeek($league, $yearInfo, "wk04", "Week 4 (26-30 Sep)", $wk_count++);
addWeek($league, $yearInfo, "wk05", "Week 5 (3-7 Oct)", $wk_count++);
addWeek($league, $yearInfo, "wk06", "Week 6 (10-14 Oct)", $wk_count++);
addWeek($league, $yearInfo, "wk07", "Week 7 (17-21 Oct)", $wk_count++);
addWeek($league, $yearInfo, "wk08", "Week 8 (24-28 Oct)", $wk_count++);
addWeek($league, $yearInfo, "wk09", "Week 9 (31 Oct - 4 Nov)", $wk_count++);
addWeek($league, $yearInfo, "wk10", "Week 10 (7-11 Nov)", $wk_count++);
addWeek($league, $yearInfo, "wk11", "Week 11 (14-18 Nov)", $wk_count++);
addWeek($league, $yearInfo, "wk12", "Week 12 (21-25 Nov)", $wk_count++);
addWeek($league, $yearInfo, "wk13", "Week 13 (28 Nov - 2 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk14", "Week 14 (5-9 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk15", "Week 15 (12-16 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk16", "Week 16 (19-21 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk17", "Week 17 (25-29 Dec)", $wk_count++);
addWeek($league, $yearInfo, "wk18", "Week 18 (5 Jan)", $wk_count++);
addWeek($league, $yearInfo, "wke1", "Postseason: Wild Card (11-13 Jan)", $wk_count++);
addWeek($league, $yearInfo, "wke2", "Postseason: Divisional (18-19 Jan)", $wk_count++);
addWeek($league, $yearInfo, "wke3", "Postseason: Conference (26 Jan)", $wk_count++);
addWeek($league, $yearInfo, "wke4", "Super Bowl (9 Feb)", $wk_count++);

# 2023 season:
$wk_count = 1;
$info{nfl}{2023}{wkb1}{date_str} = "Week 1 (7-11 Sep)";
$info{nfl}{2023}{wkName}{$wk_count} = "wkb1";
$info{nfl}{2023}{wkb1}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk02}{date_str} = "Week 2 (14-18 Sep)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk02";
$info{nfl}{2023}{wk02}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk03}{date_str} = "Week 3 (21-25 Sep)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk03";
$info{nfl}{2023}{wk03}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk04}{date_str} = "Week 4 (28 Sep - 2 Oct)"; 
$info{nfl}{2023}{wkName}{$wk_count} = "wk04";
$info{nfl}{2023}{wk04}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk05}{date_str} = "Week 5 (5-9 Oct)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk05";
$info{nfl}{2023}{wk05}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk06}{date_str} = "Week 6 (12-16 Oct)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk06";
$info{nfl}{2023}{wk06}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk07}{date_str} = "Week 7 (19-23 Oct)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk07";
$info{nfl}{2023}{wk07}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk08}{date_str} = "Week 8 (26-30 Oct)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk08";
$info{nfl}{2023}{wk08}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk09}{date_str} = "Week 9 (2-6 Nov)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk09";
$info{nfl}{2023}{wk09}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk10}{date_str} = "Week 10 (9-13 Nov)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk10";
$info{nfl}{2023}{wk10}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk11}{date_str} = "Week 11 (16-20 Nov)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk11";
$info{nfl}{2023}{wk11}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk12}{date_str} = "Week 12 (23-27 Nov)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk12";
$info{nfl}{2023}{wk12}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk13}{date_str} = "Week 13 (30 Nov - 4 Dec)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk13";
$info{nfl}{2023}{wk13}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk14}{date_str} = "Week 14 (7-11 Dec)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk14";
$info{nfl}{2023}{wk14}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk15}{date_str} = "Week 15 (14-18 Dec)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk15";
$info{nfl}{2023}{wk15}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk16}{date_str} = "Week 16 (21-25 Dec)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk16";
$info{nfl}{2023}{wk16}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk17}{date_str} = "Week 17 (28-31 Dec)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk17";
$info{nfl}{2023}{wk17}{wk_num} = $wk_count++;
$info{nfl}{2023}{wk18}{date_str} = "Week 18 (7 Jan)";
$info{nfl}{2023}{wkName}{$wk_count} = "wk18";
$info{nfl}{2023}{wk18}{wk_num} = $wk_count++;
$info{nfl}{2023}{wke1}{date_str} = "Postseason: Wild Card (13-14 Jan)";
$info{nfl}{2023}{wkName}{$wk_count} = "wke1";
$info{nfl}{2023}{wke1}{wk_num} = $wk_count++;
$info{nfl}{2023}{wke2}{date_str} = "Postseason: Divisional (20-21 Jan)";
$info{nfl}{2023}{wkName}{$wk_count} = "wke2";
$info{nfl}{2023}{wke2}{wk_num} = $wk_count++;
$info{nfl}{2023}{wke3}{date_str} = "Postseason: Conference (28 Jan)";
$info{nfl}{2023}{wkName}{$wk_count} = "wke3";
$info{nfl}{2023}{wke3}{wk_num} = $wk_count++;
$info{nfl}{2023}{wke4}{date_str} = "Super Bowl (11 Feb)";
$info{nfl}{2023}{wkName}{$wk_count} = "wke4";
$info{nfl}{2023}{wke4}{wk_num} = $wk_count++;
$info{nfl}{2023}{wke5}{date_str} = "DELETE ME";
$info{nfl}{2023}{wkName}{$wk_count} = "wke5";
$info{nfl}{2023}{wke5}{wk_num} = $wk_count++;
#
$wk_count = 1;
$info{nfl}{2022}{wkb1}{date_str} = "Week 1 (8-12 Sep)";
$info{nfl}{2022}{wkName}{$wk_count} = "wkb1";
$info{nfl}{2022}{wkb1}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk02}{date_str} = "Week 2 (15-19 Sep)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk02";
$info{nfl}{2022}{wk02}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk03}{date_str} = "Week 3 (22-26 Sep)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk03";
$info{nfl}{2022}{wk03}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk04}{date_str} = "Week 4 (29 Sep - 3 Oct)"; 
$info{nfl}{2022}{wkName}{$wk_count} = "wk04";
$info{nfl}{2022}{wk04}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk05}{date_str} = "Week 5 (6-9 Oct)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk05";
$info{nfl}{2022}{wk05}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk06}{date_str} = "Week 6 (13-17 Oct)"; # fixme continue
$info{nfl}{2022}{wkName}{$wk_count} = "wk06";
$info{nfl}{2022}{wk06}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk07}{date_str} = "Week 7 (21-25 Oct)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk07";
$info{nfl}{2022}{wk07}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk08}{date_str} = "Week 8 (28 Oct - 1 Nov)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk08";
$info{nfl}{2022}{wk08}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk09}{date_str} = "Week 9 (4-8 Nov)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk09";
$info{nfl}{2022}{wk09}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk10}{date_str} = "Week 10 (11-15 Nov)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk10";
$info{nfl}{2022}{wk10}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk11}{date_str} = "Week 11 (18-22 Nov)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk11";
$info{nfl}{2022}{wk11}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk12}{date_str} = "Week 12 (25-29 Nov)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk12";
$info{nfl}{2022}{wk12}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk13}{date_str} = "Week 13 (2-6 Dec)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk13";
$info{nfl}{2022}{wk13}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk14}{date_str} = "Week 14 (9-13 Dec)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk14";
$info{nfl}{2022}{wk14}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk15}{date_str} = "Week 15 (16-20 Dec)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk15";
$info{nfl}{2022}{wk15}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk16}{date_str} = "Week 16 (23-27 Dec)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk16";
$info{nfl}{2022}{wk16}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk17}{date_str} = "Week 17 (2-3 Jan)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk17";
$info{nfl}{2022}{wk17}{wk_num} = $wk_count++;
$info{nfl}{2022}{wk18}{date_str} = "Week 18 (9 Jan)";
$info{nfl}{2022}{wkName}{$wk_count} = "wk18";
$info{nfl}{2022}{wk18}{wk_num} = $wk_count++;
$info{nfl}{2022}{wke1}{date_str} = "Postseason: Wild Card (14-15 Jan)";
$info{nfl}{2022}{wkName}{$wk_count} = "wke1";
$info{nfl}{2022}{wke1}{wk_num} = $wk_count++;
$info{nfl}{2022}{wke2}{date_str} = "Postseason: Divisional (21-22 Jan)";
$info{nfl}{2022}{wkName}{$wk_count} = "wke2";
$info{nfl}{2022}{wke2}{wk_num} = $wk_count++;
$info{nfl}{2022}{wke3}{date_str} = "Postseason: Conference (29 Jan)";
$info{nfl}{2022}{wkName}{$wk_count} = "wke3";
$info{nfl}{2022}{wke3}{wk_num} = $wk_count++;
$info{nfl}{2022}{wke4}{date_str} = "Super Bowl (12 Feb)";
$info{nfl}{2022}{wkName}{$wk_count} = "wke4";
$info{nfl}{2022}{wke4}{wk_num} = $wk_count++;
$info{nfl}{2022}{wke5}{date_str} = "DELETE ME";
$info{nfl}{2022}{wkName}{$wk_count} = "wke5";
$info{nfl}{2022}{wke5}{wk_num} = $wk_count++;
#
$wk_count = 1;
$info{nfl}{2021}{wkb1}{date_str} = "Week 1 (9-13 Sep)";
$info{nfl}{2021}{wkName}{$wk_count} = "wkb1";
$info{nfl}{2021}{wkb1}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk02}{date_str} = "Week 2 (16-20 Sep)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk02";
$info{nfl}{2021}{wk02}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk03}{date_str} = "Week 3 (23-27 Sep)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk03";
$info{nfl}{2021}{wk03}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk04}{date_str} = "Week 4 (30 Sep - 4 Oct)"; 
$info{nfl}{2021}{wkName}{$wk_count} = "wk04";
$info{nfl}{2021}{wk04}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk05}{date_str} = "Week 5 (7-11 Oct)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk05";
$info{nfl}{2021}{wk05}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk06}{date_str} = "Week 6 (14-18 Oct)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk06";
$info{nfl}{2021}{wk06}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk07}{date_str} = "Week 7 (21-25 Oct)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk07";
$info{nfl}{2021}{wk07}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk08}{date_str} = "Week 8 (28 Oct - 1 Nov)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk08";
$info{nfl}{2021}{wk08}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk09}{date_str} = "Week 9 (4-8 Nov)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk09";
$info{nfl}{2021}{wk09}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk10}{date_str} = "Week 10 (11-15 Nov)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk10";
$info{nfl}{2021}{wk10}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk11}{date_str} = "Week 11 (18-22 Nov)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk11";
$info{nfl}{2021}{wk11}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk12}{date_str} = "Week 12 (25-29 Nov)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk12";
$info{nfl}{2021}{wk12}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk13}{date_str} = "Week 13 (2-6 Dec)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk13";
$info{nfl}{2021}{wk13}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk14}{date_str} = "Week 14 (9-13 Dec)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk14";
$info{nfl}{2021}{wk14}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk15}{date_str} = "Week 15 (16-20 Dec)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk15";
$info{nfl}{2021}{wk15}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk16}{date_str} = "Week 16 (23-27 Dec)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk16";
$info{nfl}{2021}{wk16}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk17}{date_str} = "Week 17 (2-3 Jan)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk17";
$info{nfl}{2021}{wk17}{wk_num} = $wk_count++;
$info{nfl}{2021}{wk18}{date_str} = "Week 18 (9 Jan)";
$info{nfl}{2021}{wkName}{$wk_count} = "wk18";
$info{nfl}{2021}{wk18}{wk_num} = $wk_count++;
$info{nfl}{2021}{wke1}{date_str} = "Postseason: Wild Card (15-16 Jan)";
$info{nfl}{2021}{wkName}{$wk_count} = "wke1";
$info{nfl}{2021}{wke1}{wk_num} = $wk_count++;
$info{nfl}{2021}{wke2}{date_str} = "Postseason: Divisional (22-23 Jan)";
$info{nfl}{2021}{wkName}{$wk_count} = "wke2";
$info{nfl}{2021}{wke2}{wk_num} = $wk_count++;
$info{nfl}{2021}{wke3}{date_str} = "Postseason: Conference (30 Jan)";
$info{nfl}{2021}{wkName}{$wk_count} = "wke3";
$info{nfl}{2021}{wke3}{wk_num} = $wk_count++;
$info{nfl}{2021}{wke4}{date_str} = "Super Bowl (13 Feb)";
$info{nfl}{2021}{wkName}{$wk_count} = "wke4";
$info{nfl}{2021}{wke4}{wk_num} = $wk_count++;
$info{nfl}{2021}{wke5}{date_str} = "DELETE ME";
$info{nfl}{2021}{wkName}{$wk_count} = "wke5";
$info{nfl}{2021}{wke5}{wk_num} = $wk_count++;
#
$wk_count = 1;
$info{nfl}{2020}{wkb1}{date_str} = "Week 1 (10-14 Sep)";
$info{nfl}{2020}{wkName}{$wk_count} = "wkb1";
$info{nfl}{2020}{wkb1}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk02}{date_str} = "Week 2 (17-21 Sep)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk02";
$info{nfl}{2020}{wk02}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk03}{date_str} = "Week 3 (24-28 Sep)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk03";
$info{nfl}{2020}{wk03}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk04}{date_str} = "Week 4 (1-5 Oct)"; 
$info{nfl}{2020}{wkName}{$wk_count} = "wk04";
$info{nfl}{2020}{wk04}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk05}{date_str} = "Week 5 (8-12 Oct)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk05";
$info{nfl}{2020}{wk05}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk06}{date_str} = "Week 6 (15-19 Oct)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk06";
$info{nfl}{2020}{wk06}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk07}{date_str} = "Week 7 (22-26 Oct)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk07";
$info{nfl}{2020}{wk07}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk08}{date_str} = "Week 8 (29 Oct - 2 Nov)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk08";
$info{nfl}{2020}{wk08}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk09}{date_str} = "Week 9 (5-9 Nov)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk09";
$info{nfl}{2020}{wk09}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk10}{date_str} = "Week 10 (12-16 Nov)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk10";
$info{nfl}{2020}{wk10}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk11}{date_str} = "Week 11 (19-23 Nov)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk11";
$info{nfl}{2020}{wk11}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk12}{date_str} = "Week 12 (26-30 Nov)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk12";
$info{nfl}{2020}{wk12}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk13}{date_str} = "Week 13 (3-7 Dec)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk13";
$info{nfl}{2020}{wk13}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk14}{date_str} = "Week 14 (10-14 Dec)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk14";
$info{nfl}{2020}{wk14}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk15}{date_str} = "Week 15 (17-21 Dec)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk15";
$info{nfl}{2020}{wk15}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk16}{date_str} = "Week 16 (25-28 Dec)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk16";
$info{nfl}{2020}{wk16}{wk_num} = $wk_count++;
$info{nfl}{2020}{wk17}{date_str} = "Week 17 (3 Jan)";
$info{nfl}{2020}{wkName}{$wk_count} = "wk17";
$info{nfl}{2020}{wk17}{wk_num} = $wk_count++;
$info{nfl}{2020}{wke1}{date_str} = "Postseason: Wild Card (9-10 Jan)";
$info{nfl}{2020}{wkName}{$wk_count} = "wke1";
$info{nfl}{2020}{wke1}{wk_num} = $wk_count++;
$info{nfl}{2020}{wke2}{date_str} = "Postseason: Divisional (16-17 Jan)";
$info{nfl}{2020}{wkName}{$wk_count} = "wke2";
$info{nfl}{2020}{wke2}{wk_num} = $wk_count++;
$info{nfl}{2020}{wke3}{date_str} = "Postseason: Conference (24 Jan)";
$info{nfl}{2020}{wkName}{$wk_count} = "wke3";
$info{nfl}{2020}{wke3}{wk_num} = $wk_count++;
$info{nfl}{2020}{wke4}{date_str} = "Super Bowl (7 Feb)";
$info{nfl}{2020}{wkName}{$wk_count} = "wke4";
$info{nfl}{2020}{wke4}{wk_num} = $wk_count++;
$info{nfl}{2020}{wke5}{date_str} = "DELETE ME";
$info{nfl}{2020}{wkName}{$wk_count} = "wke5";
$info{nfl}{2020}{wke5}{wk_num} = $wk_count++;
#
$wk_count = 1;
$info{nfl}{2019}{wkb1}{date_str} = "Week 1 (5-9 Sep)";
$info{nfl}{2019}{wkName}{$wk_count} = "wkb1";
$info{nfl}{2019}{wkb1}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk02}{date_str} = "Week 2 (12-16 Sep)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk02";
$info{nfl}{2019}{wk02}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk03}{date_str} = "Week 3 (19-23 Sep)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk03";
$info{nfl}{2019}{wk03}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk04}{date_str} = "Week 4 (26-30 Sep)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk04";
$info{nfl}{2019}{wk04}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk05}{date_str} = "Week 5 (3-7 Oct)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk05";
$info{nfl}{2019}{wk05}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk06}{date_str} = "Week 6 (10-14 Oct)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk06";
$info{nfl}{2019}{wk06}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk07}{date_str} = "Week 7 (17-21 Oct)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk07";
$info{nfl}{2019}{wk07}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk08}{date_str} = "Week 8 (24-28 Oct)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk08";
$info{nfl}{2019}{wk08}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk09}{date_str} = "Week 9 (31 Oct - 4 Nov)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk09";
$info{nfl}{2019}{wk09}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk10}{date_str} = "Week 10 (7-11 Nov)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk10";
$info{nfl}{2019}{wk10}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk11}{date_str} = "Week 11 (14-18 Nov)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk11";
$info{nfl}{2019}{wk11}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk12}{date_str} = "Week 12 (21-25 Nov)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk12";
$info{nfl}{2019}{wk12}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk13}{date_str} = "Week 13 (28 Nov - 2 Dec)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk13";
$info{nfl}{2019}{wk13}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk14}{date_str} = "Week 14 (5-9 Dec)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk14";
$info{nfl}{2019}{wk14}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk15}{date_str} = "Week 15 (12-16 Dec)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk15";
$info{nfl}{2019}{wk15}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk16}{date_str} = "Week 16 (22-23 Dec)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk16";
$info{nfl}{2019}{wk16}{wk_num} = $wk_count++;
$info{nfl}{2019}{wk17}{date_str} = "Week 17 (29 Dec)";
$info{nfl}{2019}{wkName}{$wk_count} = "wk17";
$info{nfl}{2019}{wk17}{wk_num} = $wk_count++;
$info{nfl}{2019}{wke1}{date_str} = "Postseason: Wild Card (4-5 Jan)";
$info{nfl}{2019}{wkName}{$wk_count} = "wke1";
$info{nfl}{2019}{wke1}{wk_num} = $wk_count++;
$info{nfl}{2019}{wke2}{date_str} = "Postseason: Divisional (11-12 Jan)";
$info{nfl}{2019}{wkName}{$wk_count} = "wke2";
$info{nfl}{2019}{wke2}{wk_num} = $wk_count++;
$info{nfl}{2019}{wke3}{date_str} = "Postseason: Conference (19 Jan)";
$info{nfl}{2019}{wkName}{$wk_count} = "wke3";
$info{nfl}{2019}{wke3}{wk_num} = $wk_count++;
$info{nfl}{2019}{wke4}{date_str} = "Super Bowl (2 Feb)";
$info{nfl}{2019}{wkName}{$wk_count} = "wke4";
$info{nfl}{2019}{wke4}{wk_num} = $wk_count++;
$info{nfl}{2019}{wke5}{date_str} = "DELETE ME";
$info{nfl}{2019}{wkName}{$wk_count} = "wke5";
$info{nfl}{2019}{wke5}{wk_num} = $wk_count++;
#
$wk_count = 1;
$info{nfl}{2018}{wkb1}{date_str} = "Week 1 (6-10 Sep)";
$info{nfl}{2018}{wkName}{$wk_count} = "wkb1";
$info{nfl}{2018}{wkb1}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk02}{date_str} = "Week 2 (13-17 Sep)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk02";
$info{nfl}{2018}{wk02}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk03}{date_str} = "Week 3 (20-24 Sep)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk03";
$info{nfl}{2018}{wk03}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk04}{date_str} = "Week 4 (27 Sep - 1 Oct)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk04";
$info{nfl}{2018}{wk04}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk05}{date_str} = "Week 5 (4-8 Oct)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk05";
$info{nfl}{2018}{wk05}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk06}{date_str} = "Week 6 (11-15 Oct)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk06";
$info{nfl}{2018}{wk06}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk07}{date_str} = "Week 7 (18-22 Oct)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk07";
$info{nfl}{2018}{wk07}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk08}{date_str} = "Week 8 (25-29 Oct)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk08";
$info{nfl}{2018}{wk08}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk09}{date_str} = "Week 9 (1-5 Nov)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk09";
$info{nfl}{2018}{wk09}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk10}{date_str} = "Week 10 (8-12 Nov)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk10";
$info{nfl}{2018}{wk10}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk11}{date_str} = "Week 11 (15-19 Nov)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk11";
$info{nfl}{2018}{wk11}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk12}{date_str} = "Week 12 (22-26 Nov)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk12";
$info{nfl}{2018}{wk12}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk13}{date_str} = "Week 13 (29 Nov - 3 Dec)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk13";
$info{nfl}{2018}{wk13}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk14}{date_str} = "Week 14 (6-10 Dec)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk14";
$info{nfl}{2018}{wk14}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk15}{date_str} = "Week 15 (13-17 Dec)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk15";
$info{nfl}{2018}{wk15}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk16}{date_str} = "Week 16 (22-24 Dec)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk16";
$info{nfl}{2018}{wk16}{wk_num} = $wk_count++;
$info{nfl}{2018}{wk17}{date_str} = "Week 17 (30 Dec)";
$info{nfl}{2018}{wkName}{$wk_count} = "wk17";
$info{nfl}{2018}{wk17}{wk_num} = $wk_count++;
$info{nfl}{2018}{wke1}{date_str} = "Postseason: Wild Card (5-6 Jan)";
$info{nfl}{2018}{wkName}{$wk_count} = "wke1";
$info{nfl}{2018}{wke1}{wk_num} = $wk_count++;
$info{nfl}{2018}{wke2}{date_str} = "Postseason: Divisional (12-13 Jan)";
$info{nfl}{2018}{wkName}{$wk_count} = "wke2";
$info{nfl}{2018}{wke2}{wk_num} = $wk_count++;
$info{nfl}{2018}{wke3}{date_str} = "Postseason: Conference (20 Jan)";
$info{nfl}{2018}{wkName}{$wk_count} = "wke3";
$info{nfl}{2018}{wke3}{wk_num} = $wk_count++;
$info{nfl}{2018}{wke4}{date_str} = "Super Bowl (3 Feb)";
$info{nfl}{2018}{wkName}{$wk_count} = "wke4";
$info{nfl}{2018}{wke4}{wk_num} = $wk_count++;
$info{nfl}{2018}{wke5}{date_str} = "DELETE ME";
$info{nfl}{2018}{wkName}{$wk_count} = "wke5";
$info{nfl}{2018}{wke5}{wk_num} = $wk_count++;
#
$info{nfl}{2017}{wk01}{date_str} = "Week 1 (7-11 Sep)";
$info{nfl}{2017}{wk02}{date_str} = "Week 2 (14-18 Sep)";
$info{nfl}{2017}{wk03}{date_str} = "Week 3 (21-25 Sep)";
$info{nfl}{2017}{wk04}{date_str} = "Week 4 (28 Sep - 2 Oct)";
$info{nfl}{2017}{wk05}{date_str} = "Week 5 (5-9 Oct)";
$info{nfl}{2017}{wk06}{date_str} = "Week 6 (12-16 Oct)";
$info{nfl}{2017}{wk07}{date_str} = "Week 7 (19-23 Oct)";
$info{nfl}{2017}{wk08}{date_str} = "Week 8 (26-30 Oct)";
$info{nfl}{2017}{wk09}{date_str} = "Week 9 (2-6 Nov)";
$info{nfl}{2017}{wk10}{date_str} = "Week 10 (9-13 Nov)";
$info{nfl}{2017}{wk11}{date_str} = "Week 11 (16-20 Nov)";
$info{nfl}{2017}{wk12}{date_str} = "Week 12 (23-27 Nov)";
$info{nfl}{2017}{wk13}{date_str} = "Week 13 (30 Nov - 4 Dec)";
$info{nfl}{2017}{wk14}{date_str} = "Week 14 (10-11 Dec)";
$info{nfl}{2017}{wk15}{date_str} = "Week 15 (14-18 Dec)";
$info{nfl}{2017}{wk16}{date_str} = "Week 16 (23-25 Dec)";
$info{nfl}{2017}{wk17}{date_str} = "Week 17 (31 Dec)";
$info{nfl}{2017}{wk18}{date_str} = "Postseason: Wild Card (6-7 Jan)";
$info{nfl}{2017}{wk19}{date_str} = "Postseason: Divisional (13-14 Jan)";
$info{nfl}{2017}{wk20}{date_str} = "Postseason: Conference (21 Jan)";
$info{nfl}{2017}{wk21}{date_str} = "Super Bowl (4 Feb)";
$info{nfl}{2017}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2016}{wk01}{date_str} = "Week 1 (8-9 Sep)";
$info{nfl}{2016}{wk02}{date_str} = "Week 2 (15-19 Sep)";
$info{nfl}{2016}{wk03}{date_str} = "Week 3 (22-26 Sep)";
$info{nfl}{2016}{wk04}{date_str} = "Week 4 (29 Sep - 3 Oct)";
$info{nfl}{2016}{wk05}{date_str} = "Week 5 (5-10 Oct)";
$info{nfl}{2016}{wk06}{date_str} = "Week 6 (13-17 Oct)";
$info{nfl}{2016}{wk07}{date_str} = "Week 7 (20-24 Oct)";
$info{nfl}{2016}{wk08}{date_str} = "Week 8 (27-31 Oct)";
$info{nfl}{2016}{wk09}{date_str} = "Week 9 (3-7 Nov)";
$info{nfl}{2016}{wk10}{date_str} = "Week 10 (10-14 Nov)";
$info{nfl}{2016}{wk11}{date_str} = "Week 11 (17-21 Nov)";
$info{nfl}{2016}{wk12}{date_str} = "Week 12 (24-28 Nov)";
$info{nfl}{2016}{wk13}{date_str} = "Week 13 (1-5 Dec)";
$info{nfl}{2016}{wk14}{date_str} = "Week 14 (8-12 Dec)";
$info{nfl}{2016}{wk15}{date_str} = "Week 15 (15-19 Dec)";
$info{nfl}{2016}{wk16}{date_str} = "Week 16 (22-26 Dec)";
$info{nfl}{2016}{wk17}{date_str} = "Week 17 (1 Jan)";
$info{nfl}{2016}{wk18}{date_str} = "Postseason: Wild Card (7-8 Jan)";
$info{nfl}{2016}{wk19}{date_str} = "Postseason: Divisional (14-15 Jan)";
$info{nfl}{2016}{wk20}{date_str} = "Postseason: Conference (22 Jan)";
$info{nfl}{2016}{wk21}{date_str} = "Super Bowl (5 Feb)";
$info{nfl}{2016}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2015}{wk01}{date_str} = "Week 1 (10-14 Sep)";
$info{nfl}{2015}{wk02}{date_str} = "Week 2 (17-21 Sep)";
$info{nfl}{2015}{wk03}{date_str} = "Week 3 (24-28 Sep)";
$info{nfl}{2015}{wk04}{date_str} = "Week 4 (1-5 Oct)";
$info{nfl}{2015}{wk05}{date_str} = "Week 5 (8-12 Oct)";
$info{nfl}{2015}{wk06}{date_str} = "Week 6 (15-19 Oct)";
$info{nfl}{2015}{wk07}{date_str} = "Week 7 (22-26 Oct)";
$info{nfl}{2015}{wk08}{date_str} = "Week 8 (29 Oct - 2 Nov)";
$info{nfl}{2015}{wk09}{date_str} = "Week 9 (6-10 Nov)";
$info{nfl}{2015}{wk10}{date_str} = "Week 10 (12-16 Nov)";
$info{nfl}{2015}{wk11}{date_str} = "Week 11 (19-23 Nov)";
$info{nfl}{2015}{wk12}{date_str} = "Week 12 (26-30 Nov)";
$info{nfl}{2015}{wk13}{date_str} = "Week 13 (3-7 Dec)";
$info{nfl}{2015}{wk14}{date_str} = "Week 14 (10-14 Dec)";
$info{nfl}{2015}{wk15}{date_str} = "Week 15 (17-21 Dec)";
$info{nfl}{2015}{wk16}{date_str} = "Week 16 (24-28 Dec)";
$info{nfl}{2015}{wk17}{date_str} = "Week 17 (3-4 Jan)";
$info{nfl}{2015}{wk18}{date_str} = "Postseason: Wild Card (9-10 Jan)";
$info{nfl}{2015}{wk19}{date_str} = "Postseason: Divisional (16-17 Jan)";
$info{nfl}{2015}{wk20}{date_str} = "Postseason: Conference (24 Jan)";
$info{nfl}{2015}{wk21}{date_str} = "Super Bowl (7 Feb)";
$info{nfl}{2015}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2014}{wk01}{date_str} = "Week 1 (4-8 Sep)";
$info{nfl}{2014}{wk02}{date_str} = "Week 2 (11-15 Sep)";
$info{nfl}{2014}{wk03}{date_str} = "Week 3 (18-22 Sep)";
$info{nfl}{2014}{wk04}{date_str} = "Week 4 (25-29 Sep)";
$info{nfl}{2014}{wk05}{date_str} = "Week 5 (2-6 Oct)";
$info{nfl}{2014}{wk06}{date_str} = "Week 6 (9-13 Oct)";
$info{nfl}{2014}{wk07}{date_str} = "Week 7 (16-20 Oct)";
$info{nfl}{2014}{wk08}{date_str} = "Week 8 (23-27 Oct)";
$info{nfl}{2014}{wk09}{date_str} = "Week 9 (30 Oct - 3 Nov)";
$info{nfl}{2014}{wk10}{date_str} = "Week 10 (6-10 Nov)";
$info{nfl}{2014}{wk11}{date_str} = "Week 11 (13-17 Nov)";
$info{nfl}{2014}{wk12}{date_str} = "Week 12 (20-24 Nov)";
$info{nfl}{2014}{wk13}{date_str} = "Week 13 (27 Nov - 1 Dec)";
$info{nfl}{2014}{wk14}{date_str} = "Week 14 (4-8 Dec)";
$info{nfl}{2014}{wk15}{date_str} = "Week 15 (11-15 Dec)";
$info{nfl}{2014}{wk16}{date_str} = "Week 16 (19-22 Dec)";
$info{nfl}{2014}{wk17}{date_str} = "Week 17 (28 Dec)";
$info{nfl}{2014}{wk18}{date_str} = "Postseason: Wild Card (3-4 Jan)";
$info{nfl}{2014}{wk19}{date_str} = "Postseason: Divisional (10-11 Jan)";
$info{nfl}{2014}{wk20}{date_str} = "Postseason: Conference (18 Jan)";
$info{nfl}{2014}{wk21}{date_str} = "Super Bowl XLIX (1 Feb)";
$info{nfl}{2014}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2013}{wk01}{date_str} = "Week 1 (5-9 Sep)";
$info{nfl}{2013}{wk02}{date_str} = "Week 2 (12-16 Sep)";
$info{nfl}{2013}{wk03}{date_str} = "Week 3 (19-23 Sep)";
$info{nfl}{2013}{wk04}{date_str} = "Week 4 (26-30 Sep)";
$info{nfl}{2013}{wk05}{date_str} = "Week 5 (3-7 Oct)";
$info{nfl}{2013}{wk06}{date_str} = "Week 6 (10-14 Oct)";
$info{nfl}{2013}{wk07}{date_str} = "Week 7 (17-21 Oct)";
$info{nfl}{2013}{wk08}{date_str} = "Week 8 (24-28 Oct)";
$info{nfl}{2013}{wk09}{date_str} = "Week 9 (31 Oct - 4 Nov)";
$info{nfl}{2013}{wk10}{date_str} = "Week 10 (7-11 Nov)";
$info{nfl}{2013}{wk11}{date_str} = "Week 11 (14-18 Nov)";
$info{nfl}{2013}{wk12}{date_str} = "Week 12 (21-25 Nov)";
$info{nfl}{2013}{wk13}{date_str} = "Week 13 (28 Nov - 2 Dec)";
$info{nfl}{2013}{wk14}{date_str} = "Week 14 (5-9 Dec)";
$info{nfl}{2013}{wk15}{date_str} = "Week 15 (12-16 Dec)";
$info{nfl}{2013}{wk16}{date_str} = "Week 16 (22-23 Dec)";
$info{nfl}{2013}{wk17}{date_str} = "Week 17 (29 Dec)";
$info{nfl}{2013}{wk18}{date_str} = "Postseason: Wild Card (4-5 Jan)";
$info{nfl}{2013}{wk19}{date_str} = "Postseason: Divisional (11-12 Jan)";
$info{nfl}{2013}{wk20}{date_str} = "Postseason: Conference (19 Jan)";
$info{nfl}{2013}{wk21}{date_str} = "Super Bowl XLVIII (2 Feb)";
$info{nfl}{2013}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2012}{wk01}{date_str} = "Week 1 (5-10 Sep)";
$info{nfl}{2012}{wk02}{date_str} = "Week 2 (13-17 Sep)";
$info{nfl}{2012}{wk03}{date_str} = "Week 3 (20-24 Sep)";
$info{nfl}{2012}{wk04}{date_str} = "Week 4 (27 Sep - 1 Oct)";
$info{nfl}{2012}{wk05}{date_str} = "Week 5 (4-8 Oct)";
$info{nfl}{2012}{wk06}{date_str} = "Week 6 (11-15 Oct)";
$info{nfl}{2012}{wk07}{date_str} = "Week 7 (18-22 Oct)";
$info{nfl}{2012}{wk08}{date_str} = "Week 8 (25-29 Oct)";
$info{nfl}{2012}{wk09}{date_str} = "Week 9 (1-5 Nov)";
$info{nfl}{2012}{wk10}{date_str} = "Week 10 (8-12 Nov)";
$info{nfl}{2012}{wk11}{date_str} = "Week 11 (15-19 Nov)";
$info{nfl}{2012}{wk12}{date_str} = "Week 12 (22-26 Nov)";
$info{nfl}{2012}{wk13}{date_str} = "Week 13 (29 Nov - 3 Dec)";
$info{nfl}{2012}{wk14}{date_str} = "Week 14 (6-10 Dec)";
$info{nfl}{2012}{wk15}{date_str} = "Week 15 (13-17 Dec)";
$info{nfl}{2012}{wk16}{date_str} = "Week 16 (22-23 Dec)";
$info{nfl}{2012}{wk17}{date_str} = "Week 17 (30 Dec)";
$info{nfl}{2012}{wk18}{date_str} = "Postseason: Wild Card (5-6 Jan)";
$info{nfl}{2012}{wk19}{date_str} = "Postseason: Divisional (12-13 Jan)";
$info{nfl}{2012}{wk20}{date_str} = "Postseason: Conference (20 Jan)";
$info{nfl}{2012}{wk21}{date_str} = "Super Bowl XLVII (3 Feb)";
$info{nfl}{2012}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2011}{wk01}{date_str} = "Week 1 (8-12 Sep)";
$info{nfl}{2011}{wk02}{date_str} = "Week 2 (18-19 Sep)";
$info{nfl}{2011}{wk03}{date_str} = "Week 3 (25-26 Sep)";
$info{nfl}{2011}{wk04}{date_str} = "Week 4 (2-3 Oct)";
$info{nfl}{2011}{wk05}{date_str} = "Week 5 (9-10 Oct)";
$info{nfl}{2011}{wk06}{date_str} = "Week 6 (16-17 Oct)";
$info{nfl}{2011}{wk07}{date_str} = "Week 7 (23-24 Oct)";
$info{nfl}{2011}{wk08}{date_str} = "Week 8 (30-31 Oct)";
$info{nfl}{2011}{wk09}{date_str} = "Week 9 (6-7 Nov)";
$info{nfl}{2011}{wk10}{date_str} = "Week 10 (10-14 Nov)";
$info{nfl}{2011}{wk11}{date_str} = "Week 11 (17-21 Nov)";
$info{nfl}{2011}{wk12}{date_str} = "Week 12 (24-28 Nov)";
$info{nfl}{2011}{wk13}{date_str} = "Week 13 (1-5 Dec)";
$info{nfl}{2011}{wk14}{date_str} = "Week 14 (8-12 Dec)";
$info{nfl}{2011}{wk15}{date_str} = "Week 15 (15-19 Dec)";
$info{nfl}{2011}{wk16}{date_str} = "Week 16 (22-26 Dec)";
$info{nfl}{2011}{wk17}{date_str} = "Week 17 (1 Jan)";
$info{nfl}{2011}{wk18}{date_str} = "Postseason: Wild Card (7-8 Jan)";
$info{nfl}{2011}{wk19}{date_str} = "Postseason: Divisional (14-15 Jan)";
$info{nfl}{2011}{wk20}{date_str} = "Postseason: Conference (23 Jan)";
$info{nfl}{2011}{wk21}{date_str} = "Super Bowl XLVI (5 Feb)";
$info{nfl}{2011}{wk22}{date_str} = "DELETE ME";
#
#
$info{nfl}{2010}{wk01}{date_str} = "Week 1 (9-13 Sep)";
$info{nfl}{2010}{wk02}{date_str} = "Week 2 (19-20 Sep)";
$info{nfl}{2010}{wk03}{date_str} = "Week 3 (26-27 Sep)";
$info{nfl}{2010}{wk04}{date_str} = "Week 4 (3-4 Oct)";
$info{nfl}{2010}{wk05}{date_str} = "Week 5 (10-11 Oct)";
$info{nfl}{2010}{wk06}{date_str} = "Week 6 (17-18 Oct)";
$info{nfl}{2010}{wk07}{date_str} = "Week 7 (24-25 Oct)";
$info{nfl}{2010}{wk08}{date_str} = "Week 8 (31 Oct - 1 Nov)";
$info{nfl}{2010}{wk09}{date_str} = "Week 9 (7-8 Nov)";
$info{nfl}{2010}{wk10}{date_str} = "Week 10 (14-15 Nov)";
$info{nfl}{2010}{wk11}{date_str} = "Week 11 (18-22 Nov)";
$info{nfl}{2010}{wk12}{date_str} = "Week 12 (25-29 Nov)";
$info{nfl}{2010}{wk13}{date_str} = "Week 13 (2-6 Dec)";
$info{nfl}{2010}{wk14}{date_str} = "Week 14 (9-13 Dec)";
$info{nfl}{2010}{wk15}{date_str} = "Week 15 (16-20 Dec)";
$info{nfl}{2010}{wk16}{date_str} = "Week 16 (23-27 Dec)";
$info{nfl}{2010}{wk17}{date_str} = "Week 17 (2 Jan)";
$info{nfl}{2010}{wk18}{date_str} = "Postseason: Wild Card (8-9 Jan)";
$info{nfl}{2010}{wk19}{date_str} = "Postseason: Divisional (15-16 Jan)";
$info{nfl}{2010}{wk20}{date_str} = "Postseason: Conference (24 Jan)";
$info{nfl}{2010}{wk21}{date_str} = "Super Bowl XLV (5 Feb)";
$info{nfl}{2010}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2009}{wk01}{date_str} = "Week 1 (10-14 Sep)";
$info{nfl}{2009}{wk02}{date_str} = "Week 2 (20-21 Sep)";
$info{nfl}{2009}{wk03}{date_str} = "Week 3 (27-28 Sep)";
$info{nfl}{2009}{wk04}{date_str} = "Week 4 (4-5 Oct)";
$info{nfl}{2009}{wk05}{date_str} = "Week 5 (11-12 Oct)";
$info{nfl}{2009}{wk06}{date_str} = "Week 6 (17-19 Oct)";
$info{nfl}{2009}{wk07}{date_str} = "Week 7 (25-26 Oct)";
$info{nfl}{2009}{wk08}{date_str} = "Week 8 (1-2 Nov)";
$info{nfl}{2009}{wk09}{date_str} = "Week 9 (8-9 Nov)";
$info{nfl}{2009}{wk10}{date_str} = "Week 10 (12-16 Nov)";
$info{nfl}{2009}{wk11}{date_str} = "Week 11 (19-23 Nov)";
$info{nfl}{2009}{wk12}{date_str} = "Week 12 (26-30 Nov)";
$info{nfl}{2009}{wk13}{date_str} = "Week 13 (3-7 Dec)";
$info{nfl}{2009}{wk14}{date_str} = "Week 14 (4-8 Dec)";
$info{nfl}{2009}{wk15}{date_str} = "Week 15 (10-14 Dec)";
$info{nfl}{2009}{wk16}{date_str} = "Week 16 (25-28 Dec)";
$info{nfl}{2009}{wk17}{date_str} = "Week 17 (3 Jan)";
$info{nfl}{2009}{wk18}{date_str} = "Postseason: Wild Card (9-10 Jan)";
$info{nfl}{2009}{wk19}{date_str} = "Postseason: Divisional (16-17 Jan)";
$info{nfl}{2009}{wk20}{date_str} = "Postseason: Conference (24 Jan)";
$info{nfl}{2009}{wk21}{date_str} = "Super Bowl XLIV (7 Feb)";
$info{nfl}{2009}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2008}{wk01}{date_str} = "Week 1 (4-8 Sep)";
$info{nfl}{2008}{wk02}{date_str} = "Week 2 (14-15 Sep)";
$info{nfl}{2008}{wk03}{date_str} = "Week 3 (21-22 Sep)";
$info{nfl}{2008}{wk04}{date_str} = "Week 4 (28-29 Sep)";
$info{nfl}{2008}{wk05}{date_str} = "Week 5 (5-6 Oct)";
$info{nfl}{2008}{wk06}{date_str} = "Week 6 (12-13 Oct)";
$info{nfl}{2008}{wk07}{date_str} = "Week 7 (19-20 Oct)";
$info{nfl}{2008}{wk08}{date_str} = "Week 8 (26-27 Oct)";
$info{nfl}{2008}{wk09}{date_str} = "Week 9 (2-3 Nov)";
$info{nfl}{2008}{wk10}{date_str} = "Week 10 (6-10 Nov)";
$info{nfl}{2008}{wk11}{date_str} = "Week 11 (13-17 Nov)";
$info{nfl}{2008}{wk12}{date_str} = "Week 12 (20-24 Nov)";
$info{nfl}{2008}{wk13}{date_str} = "Week 13 (27 Nov - 1 Dec)";
$info{nfl}{2008}{wk14}{date_str} = "Week 14 (4-8 Dec)";
$info{nfl}{2008}{wk15}{date_str} = "Week 15 (11-15 Dec)";
$info{nfl}{2008}{wk16}{date_str} = "Week 16 (18-22 Dec)";
$info{nfl}{2008}{wk17}{date_str} = "Week 17 (28 Dec)";
$info{nfl}{2008}{wk18}{date_str} = "Postseason: Wild Card (3-4 Jan)";
$info{nfl}{2008}{wk19}{date_str} = "Postseason: Divisional (10-11 Jan)";
$info{nfl}{2008}{wk20}{date_str} = "Postseason: Conference (18 Jan)";
$info{nfl}{2008}{wk21}{date_str} = "Super Bowl XLIII (1 Feb)";
$info{nfl}{2008}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2007}{wk01}{date_str} = "Week 1 (6-10 Sep)";
$info{nfl}{2007}{wk02}{date_str} = "Week 2 (16-17 Sep)";
$info{nfl}{2007}{wk03}{date_str} = "Week 3 (23-24 Sep)";
$info{nfl}{2007}{wk04}{date_str} = "Week 4 (30 Sep - 1 Oct)";
$info{nfl}{2007}{wk05}{date_str} = "Week 5 (7-8 Oct)";
$info{nfl}{2007}{wk06}{date_str} = "Week 6 (14-15 Oct)";
$info{nfl}{2007}{wk07}{date_str} = "Week 7 (21-22 Oct)";
$info{nfl}{2007}{wk08}{date_str} = "Week 8 (28-29 Oct)";
$info{nfl}{2007}{wk09}{date_str} = "Week 9 (4-5 Nov)";
$info{nfl}{2007}{wk10}{date_str} = "Week 10 (11-12 Nov)";
$info{nfl}{2007}{wk11}{date_str} = "Week 11 (18-19 Nov)";
$info{nfl}{2007}{wk12}{date_str} = "Week 12 (22-26 Nov)";
$info{nfl}{2007}{wk13}{date_str} = "Week 13 (29 Nov - 3 Dec)";
$info{nfl}{2007}{wk14}{date_str} = "Week 14 (6-10 Dec)";
$info{nfl}{2007}{wk15}{date_str} = "Week 15 (13-17 Dec)";
$info{nfl}{2007}{wk16}{date_str} = "Week 16 (20-24 Dec)";
$info{nfl}{2007}{wk17}{date_str} = "Week 17 (29-30 Dec)";
$info{nfl}{2007}{wk18}{date_str} = "Postseason: Wild Card (5-6 Jan)";
$info{nfl}{2007}{wk19}{date_str} = "Postseason: Divisional (12-13 Jan)";
$info{nfl}{2007}{wk20}{date_str} = "Postseason: Conference (20 Jan)";
$info{nfl}{2007}{wk21}{date_str} = "Super Bowl XLII (10 Feb)";
$info{nfl}{2007}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2006}{wk01}{date_str} = "Week 1 (7-11 Sep)";
$info{nfl}{2006}{wk02}{date_str} = "Week 2 (17-18 Sep)";
$info{nfl}{2006}{wk03}{date_str} = "Week 3 (24-25 Sep)";
$info{nfl}{2006}{wk04}{date_str} = "Week 4 (1-2 Oct)";
$info{nfl}{2006}{wk05}{date_str} = "Week 5 (8-9 Oct)";
$info{nfl}{2006}{wk06}{date_str} = "Week 6 (15-16 Oct)";
$info{nfl}{2006}{wk07}{date_str} = "Week 7 (22-23 Oct)";
$info{nfl}{2006}{wk08}{date_str} = "Week 8 (29-30 Oct)";
$info{nfl}{2006}{wk09}{date_str} = "Week 9 (5-6 Nov)";
$info{nfl}{2006}{wk10}{date_str} = "Week 10 (12-13 Nov)";
$info{nfl}{2006}{wk11}{date_str} = "Week 11 (19-20 Nov)";
$info{nfl}{2006}{wk12}{date_str} = "Week 12 (23-27 Nov)";
$info{nfl}{2006}{wk13}{date_str} = "Week 13 (30 Nov - 4 Dec)";
$info{nfl}{2006}{wk14}{date_str} = "Week 14 (7-11 Dec)";
$info{nfl}{2006}{wk15}{date_str} = "Week 15 (14-18 Dec)";
$info{nfl}{2006}{wk16}{date_str} = "Week 16 (21-25 Dec)";
$info{nfl}{2006}{wk17}{date_str} = "Week 17 (30-31 Dec)";
$info{nfl}{2006}{wk18}{date_str} = "Postseason: Wild Card (6-7 Jan)";
$info{nfl}{2006}{wk19}{date_str} = "Postseason: Divisional (13-14 Jan)";
$info{nfl}{2006}{wk20}{date_str} = "Postseason: Conference (21 Jan)";
$info{nfl}{2006}{wk21}{date_str} = "Super Bowl XLI (4 Feb)";
$info{nfl}{2006}{wk22}{date_str} = "Delete Me";
#
$info{nfl}{2005}{wk01}{date_str} = "Week 1 (8-12 Sep)";
$info{nfl}{2005}{wk02}{date_str} = "Week 2 (18-19 Sep)";
$info{nfl}{2005}{wk03}{date_str} = "Week 3 (25-26 Sep)";
$info{nfl}{2005}{wk04}{date_str} = "Week 4 (2-3 Oct)";
$info{nfl}{2005}{wk05}{date_str} = "Week 5 (9-10 Oct)";
$info{nfl}{2005}{wk06}{date_str} = "Week 6 (16-17 Oct)";
$info{nfl}{2005}{wk07}{date_str} = "Week 7 (21-24 Oct)";
$info{nfl}{2005}{wk08}{date_str} = "Week 8 (30-31 Oct)";
$info{nfl}{2005}{wk09}{date_str} = "Week 9 (6-7 Nov)";
$info{nfl}{2005}{wk10}{date_str} = "Week 10 (13-14 Nov)";
$info{nfl}{2005}{wk11}{date_str} = "Week 11 (20-21 Nov)";
$info{nfl}{2005}{wk12}{date_str} = "Week 12 (24-28 Nov)";
$info{nfl}{2005}{wk13}{date_str} = "Week 13 (4-5 Dec)";
$info{nfl}{2005}{wk14}{date_str} = "Week 14 (11-12 Dec)";
$info{nfl}{2005}{wk15}{date_str} = "Week 15 (17-19 Dec)";
$info{nfl}{2005}{wk16}{date_str} = "Week 16 (24-26 Dec)";
$info{nfl}{2005}{wk17}{date_str} = "Week 17 (31 Dec - 1 Jan)";
$info{nfl}{2005}{wk18}{date_str} = "Postseason: Wild Card (7-8 Jan)";
$info{nfl}{2005}{wk19}{date_str} = "Postseason: Divisional (14-15 Jan)";
$info{nfl}{2005}{wk20}{date_str} = "Postseason: Conference (22 Jan)";
$info{nfl}{2005}{wk21}{date_str} = "Super Bowl XL (5 Feb)";
$info{nfl}{2005}{wk22}{date_str} = "Delete Me";
#
$info{nfl}{2004}{wk01}{date_str} = "Week 1 (9-13 Sep)";
$info{nfl}{2004}{wk02}{date_str} = "Week 2 (19-20 Sep)";
$info{nfl}{2004}{wk03}{date_str} = "Week 3 (26-27 Sep)";
$info{nfl}{2004}{wk04}{date_str} = "Week 4 (3-4 Oct)";
$info{nfl}{2004}{wk05}{date_str} = "Week 5 (10-11 Oct)";
$info{nfl}{2004}{wk06}{date_str} = "Week 6 (17-18 Oct)";
$info{nfl}{2004}{wk07}{date_str} = "Week 7 (24-25 Oct)";
$info{nfl}{2004}{wk08}{date_str} = "Week 8 (31 Oct - 1 Nov)";
$info{nfl}{2004}{wk09}{date_str} = "Week 9 (7-8 Nov)";
$info{nfl}{2004}{wk10}{date_str} = "Week 10 (14-15 Nov)";
$info{nfl}{2004}{wk11}{date_str} = "Week 11 (21-22 Nov)";
$info{nfl}{2004}{wk12}{date_str} = "Week 12 (25-29 Nov)";
$info{nfl}{2004}{wk13}{date_str} = "Week 13 (5-6 Dec)";
$info{nfl}{2004}{wk14}{date_str} = "Week 14 (12-13 Dec)";
$info{nfl}{2004}{wk15}{date_str} = "Week 15 (18-20 Dec)";
$info{nfl}{2004}{wk16}{date_str} = "Week 16 (24-27 Dec)";
$info{nfl}{2004}{wk17}{date_str} = "Week 17 (2 Jan)";
$info{nfl}{2004}{wk18}{date_str} = "Postseason: Wild Card (8-9 Jan)";
$info{nfl}{2004}{wk19}{date_str} = "Postseason: Divisional (15-16 Jan)";
$info{nfl}{2004}{wk20}{date_str} = "Postseason: Conference (23 Jan)";
$info{nfl}{2004}{wk21}{date_str} = "Super Bowl XXXIX (6 Feb)";
$info{nfl}{2004}{wk22}{date_str} = "Delete Me";
#
$info{nfl}{2003}{wk01}{date_str} = "Week 1 (4-8 Sep)";
$info{nfl}{2003}{wk02}{date_str} = "Week 2 (14-15 Sep)";
$info{nfl}{2003}{wk03}{date_str} = "Week 3 (21-22 Sep)";
$info{nfl}{2003}{wk04}{date_str} = "Week 4 (28-29 Sep)";
$info{nfl}{2003}{wk05}{date_str} = "Week 5 (5-6 Oct)";
$info{nfl}{2003}{wk06}{date_str} = "Week 6 (12-13 Oct)";
$info{nfl}{2003}{wk07}{date_str} = "Week 7 (19-20 Oct)";
$info{nfl}{2003}{wk08}{date_str} = "Week 8 (26-27 Oct)";
$info{nfl}{2003}{wk09}{date_str} = "Week 9 (2-3 Nov)";
$info{nfl}{2003}{wk10}{date_str} = "Week 10 (9-10 Nov)";
$info{nfl}{2003}{wk11}{date_str} = "Week 11 (16-17 Nov)";
$info{nfl}{2003}{wk12}{date_str} = "Week 12 (23-24 Nov)";
$info{nfl}{2003}{wk13}{date_str} = "Week 13 (27 Nov - 1 Dec)";
$info{nfl}{2003}{wk14}{date_str} = "Week 14 (7-8 Dec)";
$info{nfl}{2003}{wk15}{date_str} = "Week 15 (14-15 Dec)";
$info{nfl}{2003}{wk16}{date_str} = "Week 16 (20-22 Dec)";
$info{nfl}{2003}{wk17}{date_str} = "Week 17 (27-28 Dec)";
$info{nfl}{2003}{wk18}{date_str} = "Postseason: Wild Card (2-3 Jan)";
$info{nfl}{2003}{wk19}{date_str} = "Postseason: Divisional (10-11 Jan)";
$info{nfl}{2003}{wk20}{date_str} = "Postseason: Conference (18 Jan)";
$info{nfl}{2003}{wk21}{date_str} = "Super Bowl XXXVIII (1 Feb)";
#
$info{nfl}{2002}{wk01}{date_str} = "Week 1 (5-9 Sep)";
$info{nfl}{2002}{wk02}{date_str} = "Week 2 (15-16 Sep)";
$info{nfl}{2002}{wk03}{date_str} = "Week 3 (22-23 Sep)";
$info{nfl}{2002}{wk04}{date_str} = "Week 4 (29-30 Sep)";
$info{nfl}{2002}{wk05}{date_str} = "Week 5 (6-7 Oct)";
$info{nfl}{2002}{wk06}{date_str} = "Week 6 (13-14 Oct)";
$info{nfl}{2002}{wk07}{date_str} = "Week 7 (20-21 Oct)";
$info{nfl}{2002}{wk08}{date_str} = "Week 8 (27-28 Oct)";
$info{nfl}{2002}{wk09}{date_str} = "Week 9 (3-4 Nov)";
$info{nfl}{2002}{wk10}{date_str} = "Week 10 (10-11 Nov)";
$info{nfl}{2002}{wk11}{date_str} = "Week 11 (17-18 Nov)";
$info{nfl}{2002}{wk12}{date_str} = "Week 12 (24-25 Nov)";
$info{nfl}{2002}{wk13}{date_str} = "Week 13 (28 Nov - 2 Dec)";
$info{nfl}{2002}{wk14}{date_str} = "Week 14 (8-9 Dec)";
$info{nfl}{2002}{wk15}{date_str} = "Week 15 (15-16 Dec)";
$info{nfl}{2002}{wk16}{date_str} = "Week 16 (21-23 Dec)";
$info{nfl}{2002}{wk17}{date_str} = "Week 17 (28-30 Dec)";
$info{nfl}{2002}{wk18}{date_str} = "Postseason: Wild Card (4-5 Jan)";
$info{nfl}{2002}{wk19}{date_str} = "Postseason: Divisional Playoffs (11-12 Jan)";
$info{nfl}{2002}{wk20}{date_str} = "Postseason: Conference Championships (19 Jan)";
$info{nfl}{2002}{wk21}{date_str} = "Super Bowl XXXVII (26 Jan)";
$info{nfl}{2002}{wk22}{date_str} = "DELETE ME";
#
$info{nfl}{2001}{wk03}{date_str} = "Week 3 (23-24 Sep)";
$info{nfl}{2001}{wk04}{date_str} = "Week 4 (30 Sep - 1 Oct)";
$info{nfl}{2001}{wk05}{date_str} = "Week 5 (7-8 Oct)";
$info{nfl}{2001}{wk06}{date_str} = "Week 6 (14-15 Oct)";
$info{nfl}{2001}{wk07}{date_str} = "Week 7 (18-22 Oct)";
$info{nfl}{2001}{wk08}{date_str} = "Week 8 (28-29 Oct)";
$info{nfl}{2001}{wk09}{date_str} = "Week 9 (4-5 Nov)";
$info{nfl}{2001}{wk10}{date_str} = "Week 10 (11-12 Nov)";
$info{nfl}{2001}{wk11}{date_str} = "Week 11 (18-19 Nov)";
$info{nfl}{2001}{wk12}{date_str} = "Week 12 (22-26 Nov)";
$info{nfl}{2001}{wk13}{date_str} = "Week 13 (29 Nov - 3 Dec)";
$info{nfl}{2001}{wk14}{date_str} = "Week 14 (9-10 Dec)";
$info{nfl}{2001}{wk15}{date_str} = "Week 15 (15-17 Dec)";
$info{nfl}{2001}{wk16}{date_str} = "Week 16 (22-23 Dec)";
$info{nfl}{2001}{wk17}{date_str} = "Week 17 (29-30 Dec)";
$info{nfl}{2001}{wk18}{date_str} = "Week 18 (6-7 Jan)";
$info{nfl}{2001}{wk19}{date_str} = "Postseason: Wild Card (12-13 Jan)";
$info{nfl}{2001}{wk20}{date_str} = "Postseason: Divisional Playoffs (19-20 Jan)";
$info{nfl}{2001}{wk21}{date_str} = "Postseason: Conference Championships (27 Jan)";
$info{nfl}{2001}{wk22}{date_str} = "Super Bowl XXXVI (3 Feb)";
$info{nfl}{2001}{wk23}{date_str} = "DELETE ME";

#$info{col}{2018}{wkName}{$wk_count} = "wkb0";
#$info{col}{2018}{wkb0}{wk_num} = $wk_count++;
print "::: league $league year $year week $week $info{$league}{$year}{$week}{wk_num}\n";
my $last_week_num = $info{$league}{$year}{$week}{wk_num} - 1;
my $last_week = $info{$league}{$year}{wkName}{$last_week_num};
print "::: last week $last_week\n" unless ($first_week);
#if ($week =~ /^(..)(\d{2})/) {
#  $last_week = sprintf "%s%02d", $1, $2-1;
#}
#else{
#  $last_week = "FIXME";
#}

# --- parse input arguments ---

my $blah;
my %opts = (
   "blah=s"		=> \$blah,
);

my @opts_list = keys %opts;
unless (GetOptions(%opts)) {
   die "Usage: $cmd [@opts_list]\n"
};

# --- variable declarations ---

my $www_post = qq|
<HR>

<P>
Back to:
<A HREF="http://BassettFootball.net"> 
   Bassett Football Model Home Page</A>

<P>
Please email comments or questions to
<A HREF="mailto:bfm\@BassettFootball.net">bfm\@BassettFootball.net</A>
<P>
|;
$www_post .= q"
<!-- Google Analytics -->
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-57163053-1', 'auto');
  ga('send', 'pageview');

</script>
";

# --- Do it ---

$make_pred = 0 if ($info{$league}{$year}{$week}{date_str} =~ /DELETE ME/i);

if ($make_pred) {
   makewebpred ();
}

if ($make_result) {
   makewebresult ();
   if ($make_palm) {
      makewebresult (1);
   }
}

if ($make_rank) {
   makewebrank();
}

if ($make_football) {
   makewebfootball();
}

sub makewebpred {

print "$cmd: reading model output file $modelOutputFile";
open POST, "<$modelOutputFile" or 
   die "ERROR opening file $modelOutputFile ($?)";
my @post = <POST>;
close POST;

my $pred_file = "$html_base/${league}_${yr}${week}pred.html";
print "$cmd: writing pred file $pred_file\n";
open PRED, ">$pred_file" or die "ERROR creating pred_file $pred_file";
binmode (PRED);

# print out header

print PRED 
qq|<TITLE>Bassett Football Model - $info{$league}{league_str_sm}</TITLE>

<BODY BGCOLOR="#002CAA" TEXT="#FFFFFF"
      LINK="#FFFF00" VLINK="#FF33AA" ALINK="#FFFFFF"> 

<H1> $year $info{$league}{$year}{$week}{date_str} Forecast 
     for $info{$league}{league_str} </H1>
<PRE>
|;

print "::: post @post\n";

#my @first_pass = sort, grep s/^\s*predictions: prob=0\.(\d)\d+\s(.*?)-(.*?)\s+predicted=(.*)-(.*)/$1:$2:$3:$4:$5/, @post;
#my @first_pass = sort, grep s/^\s*predictions: prob=0\.(\d)\d+\s+(.*?)-(.*?)\s+predicted=(.*)-(.*)/$1:$2:$3:$4:$5/, @post;
#my @first_pass = sort, grep s/^\s*predictions: prob=0\.(\d)\d+\s+(.*?)(.*?)\s+predicted(.*)-(.*)/$1:$2:$3:$4:$5/, @post;
my @first_pass = grep /predictions/, @post;

print "::: firstPass @first_pass\n";
my @p;

my %p;

my @second_pass; 

foreach my $pred (@first_pass)
{
   print "::: pred $pred\n";
   if ($pred =~ /^\s*predictions: prob=0\.(\d)\d+\s+(.*?)--(.*?)\s+predicted=(.*)--(.*?)\s+spread=(.*\S+)/)
   {
      push @second_pass, "$1:$2:$3:$4:$5:6";
   }
   else
   {
      die "ERROR parsing: $pred\n";
   }
}

foreach my $pred (sort @second_pass)
{
   my ($pct_str, $team1, $team2, $score1, $score2) = split /:/, $pred;
   my $formatted_pred = sprintf "   %-25.25s  over  %-25.25s  rounded predicted score:  %.1f-%.1f\n", $team1, $team2, 3.5*int($score1/3.5+0.5), 3.5*int($score2/3.5+.5);
   $p{$pct_str} ||= "";
   $p{$pct_str} .= $formatted_pred;
   print "::: p $pct_str pred $formatted_pred";
}


foreach my $pstr ( "90-100%", "80-90%", "70-80%", "60-70%", "50-60%") {

   my $p1 = substr($pstr,0,1);
   if (defined $p{$p1})
   {
      print PRED "\n$pstr chance of victory:\n\n";
      print PRED "$p{$p1}";
   }
}
print PRED qq|</PRE>
<BR>
<B> NOTE: the above scores are rounded to the nearest 3.5 points.  Exact predicted scores are not released until after game time </B>
|;

print PRED $www_post;
close PRED;

} # end makewebpred

sub makewebresult {

my $palm_fmt = shift @_;


my $file = $modelOutputFile;
print "$cmd: reading model output file $file\n";
open RESULT, "<$file" or die "ERROR opening file $file ($?)";
my @result = <RESULT>;
close RESULT;
@result = grep s/.*results: //, @result;
@result = reverse sort @result;

my $result_file;
if ($palm_fmt) {
   $result_file = "palm_colresult.txt";
} else {
   $result_file = "$html_base/${league}_${yr}${last_week}result.html";
}
print "$cmd: writing result file $result_file\n";
open ROUT, ">$result_file" or 
   die "ERROR creating result_file $result_file";
binmode (ROUT);

print ROUT 
qq|<TITLE>Bassett Football Model - $info{$league}{league_str_sm}</TITLE>

<BODY BGCOLOR="#002CAA" TEXT="#FFFFFF"
      LINK="#FFFF00" VLINK="#FF33AA" ALINK="#FFFFFF"> 

<H1> $year $info{$league}{$year}{$last_week}{date_str} Results
     for $info{$league}{league_str} </H1>
<PRE>
|  unless ($palm_fmt);

#my @summary = @result[$#result - 14 .. $#result - 7];
#my @summary = @result[$#result - 10 .. $#result - 4];
#my @summary = @result[$#result - 19 .. $#result - 13];
my @summary;
for (my $l=0; $l<=$#result; $l++) {
   if ($result[$l] =~ /\s*results by prob/) {
      @summary = @result[$l .. $l + 6];
      last;
   }
}
for (my $l=0; $l<=$#result; $l++) {
   if ($result[$l] =~ /\s*forecast probabilities/) {
      @summary = @result[$l .. $l + 9];
      last;
   }
}

print ROUT "prob winning team    actual/pred score,   losing team     actual/pred score\n\n";
my $prevProb = 1.0;
#foreach my $result (reverse sort grep s/^.*result://, @result) {
foreach my $result (@result)
{
# if ($palm_fmt) {
## 92%  95 Dayton                  70 58.3,   236 Saint Francis - Pennsy   0  1.9
#   if ($result =~
#      /^ ([\d\s]\d%)\s+(\d+)\s(.*?)\s+(\d+\s.*\d),\s+(\d+)\s(.*?)\s+(\d+\s.*\d)/)
#   {
#     print ROUT "$1\t$2 $3 $4\n\t$5 $6 $7\n";
#   }
# } else {
#   print ROUT $result;
# }
   if ($result =~ /prob=(\S+) (.*)--(.*)\sactual=(.*)--(.*) predicted=(\S+)--(\S+)/)
   {
      my ($prob, $team1, $team2, $score1, $score2, $predScore1, $predScore2) = ($1, $2, $3, $4, $5, $6, $7);
      my $resultString = sprintf "%02d%s  %-25.25s %2d/%4.1f,   %-25.25s %2d/%4.1f", int($prob*100+0.5), "%", $team1, $score1, $predScore1, $team2, $score2, $predScore2;
      print ROUT "\n" if ($prevProb >= 0.5 && $prob < 0.5);
      print ROUT "$resultString\n";
      $prevProb = $prob;
   }
   else
   {
      die "ERROR parsing result $result";
   }
   #print ROUT $result;
}

print ROUT "\n";

unless ($palm_fmt) {
   foreach my $sum (@summary) {
      print ROUT $sum;
   }

   print ROUT qq|</PRE>
<BR>
<B> NOTE: exact predicted scores are not released until after game time.</B>
|;
   print ROUT $www_post;
}

close ROUT;

} # end makewebresult

sub makewebrank {

print "$cmd: reading model output file $modelOutputFile\n";
open RANK, "<$modelOutputFile" or 
   die "ERROR opening file $modelOutputFile ($?)";
my @rnkraw = <RANK>;
close RANK;

my %rankings;

my $division = "header";
my $type;

foreach my $row (@rnkraw)
{
   chomp($row);
   if ($row =~ /::: (.*?) ?rankings for (.*)/)
   {
      ($type, $division) = ($1, $2);
      $type ||= "power";
   }
   elsif ($row =~ /^(results|predictions)/)
   {
      $division = "finished";
   }
   elsif ($division !~ /(finished|header)/)
   {
      $row =~ s/ actualWins.*//;
      $rankings{"$type-$division"} ||= "";
      $rankings{"$type-$division"} .= "$row\n";
   }
}

my %rank_str = ();

#qq|<H1> $today: Model power rankings ($info{$division}{rank_str}) for the $year season </H1>|;
$rank_str{averank}{header} = 
qq|<H1> $today: Model power rankings for the $year season </H1>|;

#qq|<H1> $today: Stephenson earned rank ($info{$division}{rank_str}) for the $year season </H1>
$rank_str{earnedrank}{header} = 
qq|<H1> $today: Stephenson earned rank for the $year season </H1>
Rankings determined by subracting a teams wins by the average number of wins other teams would get (as simulated by the Bassett Football Model) if they played their schedule.|;

foreach my $rank ("averank", "earnedrank")  {

   next if ($league =~ /nfl/ && $rank eq "earnedrank");

   my $rank_file = "$html_base/${league}_${yr}$rank.html";

   print "$cmd: writing rank file $rank_file\n";
   open ROUT, ">$rank_file" or 
      die "ERROR creating ${rank}_file $rank_file";
   binmode (ROUT);

   print ROUT 
   qq|<TITLE>Bassett Football Model - $info{$league}{league_str_sm}</TITLE>

<BODY BGCOLOR="#002CAA" TEXT="#FFFFFF"
      LINK="#FFFF00" VLINK="#FF33AA" ALINK="#FFFFFF"> 

$rank_str{$rank}{header}
<P>
|;

   print ROUT "<PRE>\n" unless ($rank eq "earnedrank");

   if ($rank eq "averank") {
      open TMPRANK, ">$league-overallrank.txt" or
         warn "ERROR opening $league-overallrank.txt ($!)";
      binmode (TMPRANK);
      print ROUT $rankings{"power-overall"} if ($league eq "nfl");
      print TMPRANK $rankings{"power-overall"};
      close TMPRANK;
      if ($league eq "col") {
         #open R2OUT, ">col-overallrank.txt";
         #binmode (R2OUT);
         #print R2OUT $rankings{"power-overall"};
         #close R2OUT;
         # for col redo temaverank
         open TMPRANK, ">$league-averank.txt" or
            warn "ERROR opening $league-averank.txt ($!)";
         print TMPRANK "FBS:\n";
         print ROUT "FBS:\n";
         #print ROUT "rnk  u spd  off  def\n";
         print TMPRANK $rankings{"power-IA"};
         print ROUT $rankings{"power-IA"};
         print TMPRANK "\nFCS:\n";
         print ROUT "\nFCS:\n";
         #print ROUT "rnk  u spd  off  def\n";
         print TMPRANK $rankings{"power-IAA"};
         print ROUT $rankings{"power-IAA"};
         close TMPRANK;
      }
   } else {
      open TMPRANK, ">$league-earnedrank.txt" or
         warn "ERROR opening $league-earnedrank.txt ($!)";
      binmode (TMPRANK);
      print ROUT "<B>Division IA</B>\n<BR>\n<PRE>\n";
      print TMPRANK "FBS:\n";
      print ROUT $rankings{"earned-IA"};
      print TMPRANK $rankings{"earned-IA"};
      print TMPRANK "\nFCS:\n";
      print ROUT "</PRE>\n<P>\n<B>Division IAA</B>\n<BR>\n<PRE>\n";
      print ROUT $rankings{"earned-IAA"};
      print TMPRANK $rankings{"earned-IAA"};
   }

   if (0 && ($rank eq "earnedrank")) {

      print ROUT qq|</PRE>
<P>
<PRE>
KEY:
    rnk - rank based on how may games the given team has won divided by
          the average number of wins other teams would get playing that
          schedule using the Bassett Football Model

      u - uncertainty in rank (e.g. u=1 would mean rank uncertain by
          approximately 1 place, u=** for uncertainty greater than 99 places)

    scr - Stephenson earned rank score: the actual wins of a team 
          subtracted by the average simulated wins of all teams if they 
          had played that team's schedule (as simulated by the model)

act w-l - actual win-loss record

sim w-l - simulated win-loss record of all teams if playing that schedule
</PRE>
|;

   } elsif (0) {

      print ROUT qq|</PRE>
<P>
<PRE>
KEY:
  rnk - rank based on how may games the given team would win if it
        played all other teams.

    u - uncertainty in rank (e.g. u=1 would mean rank uncertain by
        approximately 1 place, u=** for uncertainty greater than 99 places).

  spd - average margin of victory divided by 5 if the given team
        played all other teams.

  off - model offensive power, which roughly corresponds to average
        yards of offense per down in a model simulation.

  def - model defensive power, which roughly corresponds to average
        yards per down that the defense moves the offense back
        in a model simulation.
</PRE>
|;

   }

      print ROUT $www_post;
      close ROUT;
   }

} # end makewebrank

sub makewebfootball {

print "$cmd: reading football html file $football_html\n";
open FB, "<$football_html" or 
   die "ERROR opening file $football_html ($?)";
my @fbhtml = <FB>;
close (FB);

my @hist;
#if ($week ne "wk01")
if (!$first_week)
{
   # FIXME - read in result histogram
   @hist = `cd $league; ./dofindhist $info{$league}{league_id}_${year}wk out` if ($make_result);
   grep s/\015?\012/\n/g, @hist;
}
#print "XXX hist:\n@hist\n";

# replace rank dates

grep s/^(\s*)(.*?):(.*<!-- $league rank -->.*)$/${1}${today}:$3/, @fbhtml;

# find location of tags

my ($week_end,$hist_beg,$hist_end,$quick_beg,$quick_end);
$quick_beg = 0;
$quick_end = 0;

for (my $i=0; $i<=$#fbhtml; $i++) {
   $week_end = $i  if ($fbhtml[$i] =~ /<!-- $league weeks -->/);
   $hist_beg = $i  if ($fbhtml[$i] =~ /<!-- $league hist begin -->/);
   $hist_end = $i  if ($fbhtml[$i] =~ /<!-- $league hist end -->/);
   $quick_beg = $i  if ($fbhtml[$i] =~ /<!-- $league quick begin -->/);
   $quick_end = $i  if ($fbhtml[$i] =~ /<!-- $league quick end -->/);
}
#print "XXX hist_beg $hist_beg hist_end $hist_end\n";

# update weeks (if necessary)

die "ERRROR week $week for $league $year not defined"
   unless (exists $info{$league}{$year}{$week}{date_str});

print "::: first_week $first_week week_end $week_end\n";
unless ($fbhtml[$week_end-1] =~ /${week}pred.html/) {
   #if ($week ne "wk01")
   if (!$first_week)
   {
      $fbhtml[$week_end-1] =~ s|</A>|</A>,|;
      $fbhtml[$week_end-1] .= "     <A HREF=\"".$league."_".$yr.${last_week}.
                     "result.html\"> Results </A>\n";
   }
   $fbhtml[$week_end-1] .= 
                     "<LI> ".$info{$league}{$year}{$week}{date_str}.":\n".
                     "     <A HREF=\"".$league."_".$yr.${week}.
                     "pred.html\"> Forecast </A>\n";
}

# update quick summary

my @quick_lines;
if ($quick_beg > 0)
{
   #if ($week ne "wk01")
   if (!$first_week)
   {
      push @quick_lines, "<LI> ".$info{$league}{$year}{$last_week}{date_str}.
                         " <A HREF=\"".$league."_".$yr.${last_week}.
                         "result.html\"> Results </A>\n";
   }
      push @quick_lines, "<LI> ".$info{$league}{$year}{$week}{date_str}.
                         " <A HREF=\"".$league."_".$yr.${week}.
                         "pred.html\"> Forecast </A>\n";
}

foreach my $line (@quick_lines)
{
   $fbhtml[$quick_beg] .= $line;
}
for (my $i=$quick_beg+1; $i<=$quick_end-1; $i++) {
   $fbhtml[$i] = "";
}

# update histogram

my @hist_lines = ("<PRE>\n",@hist,
"
actual/expected = 1 -- model right on
actual/expected > 1 -- model probabilities too low (more wins than expected)
actual/expected < 1 -- model probabilities too high (less wins than expected)
</PRE>
");
@hist_lines = ""; # FIXME - update hist end
#my $hist_str = join '', @hist_lines;
#for (my $i=$hist_beg+2; $i<$hist_end-5; $i++) {
#  $fbhtml[$i] = $hist[$j];
#  $j++;
#}
if ($make_result)
{
   foreach my $line (@hist_lines)
   {
      $fbhtml[$hist_beg] .= $line;
   }
   for (my $i=$hist_beg+1; $i<=$hist_end-1; $i++) {
      $fbhtml[$i] = "";
   }
}

print "$cmd: re-writing football html file $football_html\n";
open FB, ">$football_html" or 
   die "ERROR opening file for writing $football_html ($?)";
binmode (FB);
foreach my $line (@fbhtml) {
# print "XXX line: $line";
   print FB $line;
}
close FB;

} # end makewebfootball
