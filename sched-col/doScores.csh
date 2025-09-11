#

# Save current massey from https://masseyratings.com/scores.php?s=cf2024&sub=ncaa-d1&all=1&sch=on
# to tmp-score-2023-in.txt.
#
# Trim down tmp-score-2023-in.txt to only include the current week (to avoid collisions of team1/team2 and
# to remove warnings about unused scores).

set year = 2025
set round = week02
set schedFile = ../colI-seasons-2020_2025.csv
set scoreFile = tmp-score-2025-in.txt
#set scoreFile = massey_score-2024.txt
set outFile = tmp-score-2025-out.txt

# with all diagnostics:
#convscorescol.pl $year $round $schedFile $scoreFile > $outFile
# just the scores for the week specified:
convscorescol.pl $year $round $schedFile $scoreFile | grep -v ::: > all_out.txt
WARNING > $outFile
grep -v WARNING all_out.txt > $outFile
echo "::: WARNINGS:"
grep WARNING all_out.txt
echo "::: ERRORS:"
grep ERROR all_out.txt
echo ""

echo "Searching for any ERRORs in $outFile (Doing 'grep ERROR $outFile'.  Okay if no lines follow.):"
grep ERROR $outFile

# merge back $outFile into $schedFile
