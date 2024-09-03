#

# Save current massey from https://masseyratings.com/scores.php?s=cf2023&sub=ncaa-d1&all=1&sch=on
# to tmp-score-2023-in.txt.
#
# Trim down tmp-score-2023-in.txt to only include the current week (to avoid collisions of team1/team2 and
# to remove warnings about unused scores).

set year = 2023
set round = weeke1
set schedFile = ../colI-seasons-2020_2023.csv
set scoreFile = tmp-score-2023-in.txt
set outFile = tmp-score-2023-out.txt

convscores01.pl $year $round $schedFile $scoreFile > $outFile

# merge back $outFile into $schedFile
