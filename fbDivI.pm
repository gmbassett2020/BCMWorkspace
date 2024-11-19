#! /usr/bin/perl -w

package         fbDivI;
require         Exporter;
@ISA            = qw(Exporter);
@EXPORT         = qw(std_name_col);

use strict;

#=======================================================================
# Subroutine std_name_col
#=======================================================================
#  
# This subroutine converts team names into the standard set used by
# the fb program.
#
# USAGE:
#
#    @std_names = std_name_col(@raw_names);
#
#    A null string, "", is returned for team names with no match.
#
#=======================================================================

sub std_name_col {

my @conv_list = (
  {
    name	=> "Abilene Christian",
    match_str	=> '^Abilene ?Chr',
  },
  {
    name	=> "Air Force",
    match_str	=> '^Air ?Force',
  },
  {
    name	=> "Akron",
    match_str	=> '^Akron',
  },
  {
    name	=> "Alabama",
    match_str	=> '^Alabama$|^Crimson Tide',
  },
  {
    name	=> "Alabama - Birmingham",
    match_str	=> '^Alabama - Birm|^Al.Birm|^Ala.Birm|^Alabama.Birm|UAB',
  },
  {
    name	=> "Alabama A&M",
    match_str	=> '^Alabama ?A&M$',
  },
  {
    name	=> "Alabama State",
    match_str	=> '^Alabama ?St',
  },
  {
    name	=> "Albany",
    match_str	=> '^(SUNY ?-?|)Albany( N.*Y.*|)$',
  },
  {
    name	=> "Alcorn State",
    match_str	=> '^Alcorn ?St',
  },
  {
    name	=> "Appalachian State",
    match_str	=> '^Appalachian ?St',
  },
  {
    name	=> "Arizona",
    match_str	=> '^Arizona$',
  },
  {
    name	=> "Arizona State",
    match_str	=> '^Arizona ?St',
  },
  {
    name	=> "Arkansas",
    match_str	=> '^Arkansas$',
  },
  {
    name	=> "Arkansas - Pine Bluff",
    match_str	=> '^Ark.*Pine.*Bluff$',
  },
  {
    name	=> "Arkansas State",
    match_str	=> '^Arkansas ?St',
  },
  {
    name	=> "Army",
    match_str	=> '^Army$',
  },
  {
    name	=> "Auburn",
    match_str	=> '^Auburn$',
  },
  {
    name	=> "Austin Peay",
    match_str	=> '^Austin ?Peay$',
  },
  {
    name	=> "Ball State",
    match_str	=> '^Ball ?St',
  },
  {
    name	=> "Baylor",
    match_str	=> '^Baylor$',
  },
  {
    name	=> "Bethune - Cookman",
    match_str	=> '^Bethune.*Cookman',
  },
  {
    name	=> "Boise State",
    match_str	=> '^Boise ?St',
  },
  {
    name	=> "Boston College",
    match_str	=> '^Boston ?College$|^BC$',
  },
  {
    name	=> "Boston",
    match_str	=> '^Boston ?(|University)$',
  },
  {
    name	=> "Bowling Green",
    match_str	=> '^Bowling ?Green( ?St.*|)$',
  },
  {
    name	=> "Brigham Young",
    match_str	=> '^Brigham ?Young$|^B\.?Y\.?U\.?$',
  },
  {
    name	=> "Brown",
    match_str	=> '^Brown$',
  },
  {
    name	=> "Bryant",
    match_str	=> '^Bryant$',
  },
  {
    name	=> "Bucknell",
    match_str	=> '^Bucknell$',
  },
  {
    name	=> "Buffalo",
    match_str	=> '^Buffalo$',
  },
  {
    name	=> "Butler",
    match_str	=> '^Butler$',
  },
  {
    name	=> "California",
    match_str	=> '^California$|^Cal$',
  },
  {
    name	=> "California Poly",
    match_str	=> '^Cal.*Poly',
  },
  {
    name	=> "California - Davis",
    match_str	=> '^(California|UC) ?-? ?Davis',
  },
  {
    name	=> "California - Fullerton",
    match_str	=> '^(California|UC|) ?-? ?Fullerton',
  },
  {
    name	=> "California - Long Beach",
    match_str	=> '^(California|UC|) ?-? ?Long Beach',
  },
  {
    name	=> "California - Los Angeles",
    match_str	=> '^California ?-? ?Los An|^U\.?C\.?L\.?A\.?$',
  },
  {
    name	=> "California - Santa Barbara",
    match_str	=> '^(California|UC|) ?-? ?Santa Barba',
  },
  {
    name	=> "California State - Northridge", # California St. - Northridge
    match_str	=> '^(California St\w*\.?|CSU?) ?-?( N| ?North)',
  },
  {
    name	=> "Campbell",
    match_str	=> '^Campbell$',
  },
  {
    name	=> "Canisius",
    match_str	=> '^Canisius$',
  },
  {
    name	=> "Central Arkansas",
    match_str	=> '^(Central|Cent|C)\.? ?Arkansas',
  },
  {
    name	=> "Central Connecticut",
    match_str	=> '^(Central|Cent|C)\.? ?Conn\w*\.?(|St)',
  },
#assume that Central Connecticut State is the same as Central Connecticut
#  {
#    name	=> "Central Connecticut State",
#    match_str	=> '^(Central|Cent|C)\.? ?Conn\w*\.? St',
#  },
  {
    name	=> "Central Florida",
    match_str	=> '^(Central|Cent|C)\.? ?Fl|^UCF$',
  },
  {
    name	=> "Central Michigan",
    match_str	=> '^(Central|Cent|C)\.? ?Mich',
  },
  {
    name	=> "Charleston Southern",
    match_str	=> '^Charleston ?S',
  },
  {
    name	=> "Cincinnati",
    match_str	=> '^Cincinnati$',
  },
  {
    name	=> "Clemson",
    match_str	=> '^Clemson$',
  },
  {
    name	=> "Colgate",
    match_str	=> '^Colgate$',
  },
  {
    name	=> "Colorado",
    match_str	=> '^Colorado$',
  },
  {
    name	=> "Colorado State",
    match_str	=> '^Colorado ?St',
  },
  {
    name	=> "Columbia",
    match_str	=> '^Columbia$',
  },
  {
    name	=> "Connecticut",
    match_str	=> '^Connecticut$',
  },
  {
    name	=> "Cornell",
    match_str	=> '^Cornell( ?-?N.*Y|$)',
  },
  {
    name	=> "Coastal Carolina",
    match_str	=> '^Coastal Car',
  },
  {
    name	=> "Dartmouth",
    match_str	=> '^Dartmouth$',
  },
  {
    name	=> "Davidson",
    match_str	=> '^Davidson$',
  },
  {
    name	=> "Dayton",
    match_str	=> '^Dayton$',
  },
  {
    name	=> "Delaware",
    match_str	=> '^Delaware$',
  },
  {
    name	=> "Delaware State",
    match_str	=> '^Delaware ?St',
  },
  {
    name	=> "Denver",
    match_str	=> '^Denver$',
  },
  {
    name	=> "Detroit Mercy",
    match_str	=> '^Detroit Mercy$',
  },
  {
    name	=> "Drake",
    match_str	=> '^Drake$',
  },
  {
    name	=> "Duke",
    match_str	=> '^Duke$',
  },
  {
    name	=> "Duquesne",
    match_str	=> '^Duquesne$',
  },
  {
    name	=> "East Carolina",
    match_str	=> '^(East|E)\.? ?Carolina$',
  },
  {
    name	=> "East Tennessee State",
    match_str	=> '^(East|E)\.? ?Tenn\w*\.? St|^ETSU|^East ?Tennessee$',
  },
  {
    name	=> "Eastern Illinois",
    match_str	=> '^(East.?rn|East)\.? ?Ill|^E\.? Ill',
  },
  {
    name	=> "Eastern Kentucky",
    match_str	=> '^(East.?rn|East|E)\.? ?(Kent|Ky)',
  },
  {
    name	=> "Eastern Michigan",
    match_str	=> '^(East.?rn|East|E)\.? ?Mich',
  },
  {
    name	=> "Eastern Washington",
    match_str	=> '^(East.?rn|East|E)\.? ?Wash',
  },
  {
    name	=> "Elon",
    match_str	=> '^Elon',
  },
  {
    name	=> "Fairfield",
    match_str	=> '^Fairfield$',
  },
  {
    name	=> "Florida",
    match_str	=> '^(Florida|Fla)$|^Gators',
  },
  {
    name	=> "Florida A&M",
    match_str	=> '^(Florida|Fla) ?A&M$',
  },
  {
    name	=> "Florida Atlantic",
    match_str	=> '^(Florida|Fla|FL) Atl',
  },
  {
    name	=> "Florida State",
    match_str	=> '^(Florida|Fla) ?St',
  },
  {
    name	=> "Florida International",
    match_str	=> '^(Florida|Fla) ?(Inter|Int.?l)',
  },
  {
    name	=> "Fordham",
    match_str	=> '^Fordham$',
  },
  {
    name	=> "Fresno State",
    match_str	=> '^Fresno ?St',
  },
  {
    name	=> "Furman",
    match_str	=> '^Furman$',
  },
  {
    name	=> "Gardner - Webb",
    match_str	=> '^Gardner ?-? ?Webb$',
  },
  {
    name	=> "George Washington",
    match_str	=> '^George Wa.',
  },
  {
    name	=> "Georgetown",
    match_str	=> '^Georgetown(|,?-? ?\(?D\.?C\.?\)?)$',
                                          # I believe Georgetown DC not KY
  },
  {
    name	=> "Georgia",
    match_str	=> '^Georgia$',
  },
  {
    name	=> "Georgia Southern",
    match_str	=> '^(Geo|Ga)\w*\.? So|^Georgia ?So',
       # Southern assumed different
  },
  {
    name	=> "Georgia State",
    match_str	=> '^(Geo|Ga)\w*\.? St|^Georgia ?St',
  },
  {
    name	=> "Georgia Tech",
    match_str	=> '^Georgia ?Tech$',
  },
  {
    name	=> "Grambling",
    match_str	=> '^Grambling',
  },
  {
    name	=> "Hampton",
    match_str	=> '^Hampton',
  },
  {
    name	=> "Hardin-Simmons",
    match_str	=> '^Hardin-Simmons',
  },
  {
    name	=> "Harvard",
    match_str	=> '^Harvard$',
  },
  {
    name	=> "Hawaii",
    match_str	=> '^Hawai.?i$',
  },
  {
    name	=> "Hofstra",
    match_str	=> '^Hofstra$',
  },
  {
    name	=> "Holy Cross",
    match_str	=> '^Holy ?Cross$',
  },
  {
    name	=> "Houston",
    match_str	=> '^Houston$',
  },
  {
    name	=> "Houston Christian",
    match_str	=> '^Houston Bap|HBU|HCU|Houston Chr',
    # name changed from Houston Baptist to Houston Christian by start of 2023 season.
  },
  {
    name	=> "Howard",
    match_str	=> '^Howard$',  # also a Howard Payne
  },
  {
    name	=> "Idaho",
    match_str	=> '^Idaho$',
  },
  {
    name	=> "Idaho State",
    match_str	=> '^Idaho ?St',
  },
  {
    name	=> "Illinois",
    match_str	=> '^Illinois$',
  },
  {
    name	=> "Illinois State",
    match_str	=> '^Illinois ?St',
  },
  {
    name	=> "Incarnate Word",
    match_str	=> '^Incarnate Word|UIW',
  },
  {
    name	=> "Indiana",
    match_str	=> '^Indiana$',
  },
  {
    name	=> "Indiana State",
    match_str	=> '^Indiana ?St',
  },
  {
    name	=> "Iona",
    match_str	=> '^Iona$',
  },
  {
    name	=> "Iowa",
    match_str	=> '^Iowa$',
  },
  {
    name	=> "Iowa State",
    match_str	=> '^Iowa ?St',
  },
  {
    name	=> "Jackson State",
    match_str	=> '^Jackson ?St',
  },
  {
    name	=> "Jacksonville",
    match_str	=> '^Jacksonville(| F\w*\.?|\(?FL\)?)$',
  },
  {
    name	=> "Jacksonville State",
    match_str	=> '^Jacksonville ?St',
  },
  {
    name	=> "James Madison",
    match_str	=> '^James ?Madison$',
  },
  {
    name	=> "Kansas",
    match_str	=> '^Kansas$',
  },
  {
    name	=> "Kansas State",
    match_str	=> '^Kansas ?St',
  },
  {
    name	=> "Kennesaw State",
    match_str	=> '^Kennesaw( ?St.*|)',
  },
  {
    name	=> "Kent State",
    match_str	=> '^Kent(| ?St.*)$',
  },
  {
    name	=> "Kentucky",
    match_str	=> '^Kentucky$',
  },
  {
    name	=> "La Salle",
    match_str	=> '^La ?Salle$',
  },
  {
    name	=> "Long Island",
    match_str	=> '^(Long Island|LIU)',
  },
  {
    name	=> "Los Angeles State",
    match_str	=> '^Los Angeles ?St',
  },
  {
    name	=> "Lafayette",
    match_str	=> '^Lafayette$',
    # 2003-09-04 Note: Louisiana - Lafayette (Southwestern Louisiana (?)) 
    # is a separate school from Lafayette
  },
  {
    name	=> "Lamar",
    match_str	=> '^Lamar',
  },
  {
    name	=> "Lehigh",
    match_str	=> '^Lehigh$',
  },
  {
    name	=> "Liberty",
    match_str	=> '^Liberty$',
  },
  {
    name	=> "Lindenwood",
    match_str	=> '^Lindenwood',
  },
  {
    name	=> "Louisiana State",
    match_str	=> '^Louisiana ?St|^L\.?S\.?U\.?',
  },
  {
    name	=> "Louisiana Tech",
    match_str	=> '^(Louisiana|LA) ?Tech$',
  },
  {
    #name	=> "Southwestern Louisiana",
    name	=> "Louisiana - Lafayette",
    match_str	=> '^(Southwest.?rn|Southwest|SW)\.? ?Louis|'. 
                   '^(LA|La\.|Louisiana|UL) ?-? ?Lafayette$|^Louisiana$',
    # 2003-09-04 was Southwestern Louisiana 1998-2002 - FIXME
    # 2021-08-17 Do not match "SE Louisiana"
  },
  {
    name	=> "Louisville",
    match_str	=> '^Louisville$',
  },
  {
    name	=> "Maine",
    match_str	=> '^Maine$',
  },
  {
    name	=> "Marist",
    match_str	=> '^Marist$',
  },
  {
    name	=> "Marquette",
    match_str	=> '^Marquette$',
  },
  {
    name	=> "Marshall",
    match_str	=> '^Marshall$',
  },
  {
    name	=> "Maryland",
    match_str	=> '^Maryland$',
  },
  {
    name	=> "Massachusetts",
    match_str	=> '^Massachusetts$',
  },
  {
    name	=> "McNeese State",
    match_str	=> '^McNeese ?St',
  },
  {
    name	=> "Memphis",
    match_str	=> '^Memphis',
  },
  {
    name	=> "Mercer",
    match_str	=> '^Mercer$',
  },
  {
    name	=> "Merrimack",
    match_str	=> '^Merrimack$',
  },
  {
    name	=> "Miami - Florida",
    match_str	=> '^Miami.*Fl|^Miami$',
  },
  {
    name	=> "Miami - Ohio",
    match_str	=> '^Miami.*Oh',
  },
  {
    name	=> "Michigan",
    match_str	=> '^Michigan$',
  },
  {
    name	=> "Michigan State",
    match_str	=> '^Michigan ?St',
  },
  {
    name	=> "Middle Tennessee State",
    match_str	=> '^Mid\w*\.? ?Tenn|MTSU',
  },
  {
    name	=> "Minnesota",
    match_str	=> '^Minnesota$',
  },
  {
    name	=> "Mississippi",
    match_str	=> '^Mississippi$|^Ole Miss',
  },
  {
    name	=> "Mississippi State",
    match_str	=> '^Mississippi ?St|^Miss.St|^MSU Bulldogs',
  },
  {
    name	=> "Mississippi Valley State",
    match_str	=> '^((Miss\w*|MS)\.? ?Valley ?St|^MVSU)',
  },
  {
    name	=> "Missouri",
    match_str	=> '^Missouri$',
  },
  {
    name	=> "Missouri State",
    match_str	=> '^Missouri ?St',
  },
  {
    name	=> "Monmouth",
    match_str	=> '^Monmouth',
  },
  {
    name	=> "Montana",
    match_str	=> '^Montana$',
  },
  {
    name	=> "Montana State",
    match_str	=> '^Montana ?St',
  },
  {
    name	=> "Morehead State",
    match_str	=> '^Morehead ?St',
  },
  {
    name	=> "Morgan State",
    match_str	=> '^Morgan ?St',
  },
  {
    name	=> "Morris Brown",
    match_str	=> '^Morris Brown',
  },
  {
    name	=> "Murray State",
    match_str	=> '^Murray ?St',
  },
  {
    name	=> "Navy",
    match_str	=> '^Navy$',
  },
  {
    name	=> "Nebraska",
    match_str	=> '^Nebraska$|^Cornhuskers$',
  },
  {
    name	=> "Nevada - Reno",
    match_str	=> '^Nevada$|^Nevada ?-? ?Reno',
  },
  {
    name	=> "Nevada - Las Vegas",
    match_str	=> '^Nevada ?-? ?Las V|^Nev Las V|^U\.?N\.?L\.?V\.?$',
  },
  {
    name	=> "New Hampshire",
    match_str	=> '^New ?Hampshire$',
  },
  {
    name	=> "New Mexico",
    match_str	=> '^New ?Mexico$',
  },
  {
    name	=> "New Mexico State",
    match_str	=> '^New ?Mexico ?St',
  },
  {
    name	=> "Nicholls State",
    match_str	=> '^Nicholls ?St',
  },
  {
    name	=> "Norfolk State",
    match_str	=> '^Norfolk ?St',
  },
  {
    name	=> "North Dakota",
    match_str	=> '^(North|N|No)\.? ?Dakota$',
  },
  {
    name	=> "North Dakota State",
    match_str	=> '^(North|N|No)\.? ?Dakota ?St',
  },
  {
    name	=> "North Alabama",
    match_str	=> '^(North|N|No).?Alabama$',
  },
  {
    name	=> "North Carolina",
    match_str	=> '^(North|N|No).?Carolina$',
  },
  {
    name	=> "North Carolina - Charlotte",
    match_str	=> '^Charlotte|(North|N|No).?(Carolina|C) ?.? ?Charl',
  },
  {
    name	=> "North Carolina A&T",
    match_str	=> '^(North|N|No)\.? ?(Carolina|C)\.? ?A&T$',
  },
  {
    name	=> "North Carolina Central",
    match_str	=> '^(North|N|No)\.? ?(Carolina|C)\.? ?Ce',
  },
  {
    name	=> "North Carolina State",
    match_str	=> '^(North|N|No)\.? ?(Carolina|C)\.? ?St',
  },
  {
    name	=> "North Texas",
    match_str	=> '^North ?Texas$|N.Texas$',
  },
  {
    name	=> "Northeast Louisiana",
    match_str	=> '^Northeast ?Louis|^NE.Louis|'.
                   '^(Louisiana|LA|La\.) ?- ?Monroe|^UL ?-?Monroe$|ULM',
  },
  {
    name	=> "Northeastern",
    match_str	=> '^Northeastern$',
  },
  {
    name	=> "Northern Arizona",
    match_str	=> '^(North.?rn|No|N)\.? ?Arizona',
  },
  {
    name	=> "Northern Colorado",
    match_str	=> '^(North.?rn|No|N)\.? ?Colorado',
  },
  {
    name	=> "Northern Illinois",
    match_str	=> '^(North.?rn|No)\.? ?Ill|^N\.? Ill',
  },
  {
    name	=> "Northern Iowa",
    match_str	=> '^(North.?rn|No|N)\.? ?Iowa',
  },
  {
    name	=> "Northwestern",
    match_str	=> '^Northwest.?rn$',
  },
  {
    name	=> "Northwestern State",
    match_str	=> '^Northwest.?rn St|N\w*[Ww]\w* ?(Louisiana|\(?LA\)?)$',
  },
  {
    name	=> "Notre Dame",
    match_str	=> '^Notre ?Dame$',
  },
  {
    name	=> "Ohio",
    match_str	=> '^Ohio$|^Ohio ?U',
  },
  {
    name	=> "Ohio State",
    match_str	=> '^Ohio ?St',
  },
  {
    name	=> "Oklahoma",
    match_str	=> '^Oklahoma$',
  },
  {
    name	=> "Oklahoma State",
    match_str	=> '^Oklahoma ?St',
  },
  {
    name	=> "Old Dominion",
    match_str	=> '^Old Dominion',
  },
  {
    name	=> "Oregon",
    match_str	=> '^Oregon$',
  },
  {
    name	=> "Oregon State",
    match_str	=> '^Oregon ?St',
  },
  {
    name	=> "Pacific",
    match_str	=> '^Pacific$',
  },
  {
    name	=> "Penn State",
    match_str	=> '^Penn ?St',
  },
  {
    name	=> "Pennsylvania",
    match_str	=> '^Pennsylvania$|^Penn$',
  },
  {
    name	=> "Pittsburgh",
    match_str	=> '^Pittsburgh$',
  },
  {
    name	=> "Portland State",
    match_str	=> '^Portland ?St',
  },
  {
    name	=> "Prairie View",
    match_str	=> '^Prairie ?View(| ?A&M)$',
  },
  {
    name	=> "Presbyterian",
    match_str	=> '^Presbyterian$',
  },
  {
    name	=> "Princeton",
    match_str	=> '^Princeton$',
  },
  {
    name	=> "Purdue",
    match_str	=> '^Purdue$',
  },
  {
    name	=> "Quantico Marines",
    match_str	=> '^Quantico Marines$',
  },
  {
    name	=> "Rhode Island",
    match_str	=> '^Rhode ?Island$',
  },
  {
    name	=> "Rice",
    match_str	=> '^Rice$',
  },
  {
    name	=> "Richmond",
    match_str	=> '^Richmond$',
  },
  {
    name	=> "Robert Morris",
    match_str	=> '^Robert ?Morris($| ?-?P.*)',
  },
  {
    name	=> "Rutgers",
    match_str	=> '^Rutgers$',
  },
  {
    name	=> "Sacramento State",
    match_str	=> '^Sacramento ?St|^CSU? ?-?Sacramento',
  },
  {
    name	=> "Sacred Heart",
    match_str	=> '^Sacred ?Heart$',
  },
  {
    name	=> "Saint Francis - Pennsylvania",
    match_str	=> '^(Saint|St\.|St) ?Francis\S*\s*(|,|-)\s*\(?P.*$',
       # there also ones in Ill, Ind
  },
  {
    name	=> "Saint John's",
    match_str	=> '^(Saint|St.?) ?John.?s(|\s?(,|-|) ?\(?N.*Y.*\)?)$',
  },
  {
    name	=> "Saint Mary's",
    match_str	=> '^(Saint|St.?) ?Mary.?s',
  },
  {
    name	=> "Saint Peter's",
    match_str	=> '^(Saint|St.?) ?Peter.?s$',
  },
  {
    name	=> "Saint Thomas - Minnesota",
    match_str	=> '^(Saint|St\.|St) ?Thomas\S*\s*(|,|-)\s*\(?M.*$',
  },
  {
    name	=> "Sam Houston State",
    match_str	=> '^Sam ?Houston ?St',
  },
  {
    name	=> "Samford",
    match_str	=> '^Samford$',
  },
  {
    name	=> "San Diego",
    match_str	=> '^San ?Diego$',
  },
  {
    name	=> "San Diego State",
    match_str	=> '^San ?Diego ?St',
  },
  {
    name	=> "San Jose State",
    match_str	=> '^San ?Jos\S+ ?St',
  },
  {
    name	=> "Savannah State",
    match_str	=> '^Savannah',
  },
  {
    name	=> "Siena",
    match_str	=> '^Siena$',
  },
  {
    name	=> "South Alabama",
    match_str	=> '^(South|So|S)\.? ?Alabama$',
  },
  {
    name	=> "South Carolina",
    match_str	=> '^(South|So|S)\.? ?Carolina$',
  },
  {
    name	=> "South Carolina State",
    match_str	=> '^(South|So|S)\.? ?(Carolina|C\.?) ?St',
  },
  {
    name	=> "South Dakota",
    match_str	=> '^(South|So|S)\.? ?Dakota$',
  },
  {
    name	=> "South Dakota State",
    match_str	=> '^(South|So|S)\.? ?Dakota ?St',
  },
  {
    name	=> "South Florida",
    match_str	=> '^(South|So|S)\.? ?(Florida|Fla)$',
  },
  {
    name	=> "Southeast Louisiana",
    match_str	=> '^(Southeast|Southeastern|SE)\.? ?Louisiana', 
  },
  {
    name	=> "Southeast Missouri State",
    match_str	=> '^(Southeast|SE)\.? ?Missouri',  # "SE Missouri" used
  },
  {
    name	=> "Southern",  # assumed different than Georgia Southern
    match_str	=> '^Southern$|^Southern U[^t]\S*$',
  },
  {
    name	=> "Southern California",
    match_str	=> '^(South.?rn|So|Sou|S)\.? ?Cal|^USC$|^u\$c$',
  },
  {
    name	=> "Southern Illinois",
    match_str	=> '^(South.?rn|So|Sou)\.? ?Ill|^S\.? Ill',
  },
  {
    name	=> "Southern Methodist",
    match_str	=> '^(South.?rn|So|Sou|S)\.? ?Methodist$|^S\.?M\.?U\.?$',
  },
  {
    name	=> "Southern Mississippi",
    match_str	=> '^(South.?rn|So|Sou)\.? ?Miss|^S\.? Miss',
  },
  {
    name	=> "Southern Utah",
    match_str	=> '^(South.?rn|Sou)\.? ?Ut|^S\.? Ut|^So\.? Ut',
  },
  {
    name	=> "Southwest Missouri State",
    match_str	=> '^((Southwest|SW)\.? ?Missouri|Missouri St)', 
  },
  {
    name	=> "Stetson",
    match_str	=> '^Stetson$',
  },
  {
    name	=> "Tampa",
    match_str	=> '^Tampa$',
  },
  {
    name	=> "Texas State - San Marcos",
    match_str	=> '^(Southwest|SW|)\.? ?Texas ?Sta?t?e?\.? ?-? ?(|San Marcos)',
    # 2004-09-01 assume same as texas st - san marcos
  },
  {
    name	=> "Stanford",
    match_str	=> '^Stanford$',
  },
  {
    name	=> "Stephen F. Austin",
    match_str	=> '^(S.*Austin|S.?F.?A.?)$',
  },
  {
    name	=> "Stonehill",
    match_str	=> '^Stonehill',
  },
  {
    name	=> "Stony Brook",
    match_str	=> '^(|SUNY ?-? ?)Stony ?Brook$',
  },
  {
    name	=> "Syracuse",
    match_str	=> '^Syracuse$',
  },
  {
    name	=> "Tarleton State",
    match_str	=> '^Tarleton ?St',
  },
  {
    name	=> "Temple",
    match_str	=> '^Temple$',
  },
  {
    name	=> "Tennessee",
    match_str	=> '^Tennessee$',
  },
  {
    name	=> "Tennessee - Chattanooga",
    match_str	=> '^Tenn\w*\.? ?-? ?Chatt|^(UT-|UT ?|)Chattanooga',
  },
  {
    name	=> "Tennessee - Martin",
    match_str	=> '^(Tenn|TN)\w*\.? ?-? ?Martin',
  },
  {
    name	=> "Tennessee State",
    match_str	=> '^Tennessee ?St',
  },
  {
    name	=> "Tennessee Tech",
    match_str	=> '^Tennessee ?Tech$',
  },
  {
    name	=> "Texas",
    match_str	=> '^Texas$|^Longhorns',
  },
  {
    name	=> "Texas - Arlington",
    match_str	=> '^Texas ?-? ?Arlington$',
  },
  {
    name	=> "Texas - El Paso",
    match_str	=> '^Texas ?-? ?El ?Paso$|^UTEP$',
  },
  {
    name	=> "Texas - San Antonio",
    match_str	=> '^(Texas ?-? ?San ?Antonio|UTSA|UT San Antonio)$',
  },
  {
    name	=> "Texas A&M",
    match_str	=> '^Texas ?A&M$',
  },
  {
    name	=> "Texas A&M-Commerce",
    match_str	=> '^((Texas|TX) ?A&M(-| )Commerce|East (Texas|TX) ?A&M)$',
  },
  {
    name	=> "Texas Christian",
    match_str	=> '^(Texas|TX|Tex) ?Christian$|^T\.?C\.?U\.?$',
  },
  {
    name	=> "Texas Southern",
    match_str	=> '^(Texas|TX) ?So',
  },
  {
    name	=> "Texas Tech",
    match_str	=> '^Texas ?Tech$',
  },
  {
    name	=> "The Citadel",
    match_str	=> 'Citadel$',
  },
  {
    name	=> "Toledo",
    match_str	=> '^Toledo$',
  },
  {
    name	=> "Towson",
    match_str	=> '^Towson', # assum Towson & Towson St are the same
  },
  {
    name	=> "Troy State",
    match_str	=> '^Troy ?S?t?',
  },
  {
    name	=> "Tulane",
    match_str	=> '^Tulane$',
  },
  {
    name	=> "Tulsa",
    match_str	=> '^Tulsa$',
  },
  {
    name	=> "Utah",
    match_str	=> '^Utah$',
  },
  {
    name	=> "Utah State",
    match_str	=> '^Utah ?St',
  },
  {
    name	=> "Utah Tech", # AKA Dixie State
    match_str	=> '^(Dixie ?St|Utah ?Tech)',
  },
  {
    name	=> "Valparaiso",
    match_str	=> '^Valparaiso$',
  },
  {
    name	=> "Vanderbilt",
    match_str	=> '^Vanderbilt$',
  },
  {
    name	=> "Villanova",
    match_str	=> '^Villanova$',
  },
  {
    name	=> "Virginia",
    match_str	=> '^Virginia$',
  },
  {
    name	=> "Virginia Military",
    match_str	=> '^((Virginia|Va) ?Military.*|VMI)$',
  },
  {
    name	=> "Virginia Tech",
    match_str	=> '^(Virginia|Va) ?Tech$',
  },
  {
    name	=> "Wagner",
    match_str	=> '^Wagner$',
  },
  {
    name	=> "Wake Forest",
    match_str	=> '^Wake ?Forest$',
  },
  {
    name	=> "Washington",
    match_str	=> '^Washington$',
  },
  {
    name	=> "Washington State",
    match_str	=> '^Washington ?St',
  },
  {
    name	=> "Weber State",
    match_str	=> '^Weber ?St',
  },
  {
    name	=> "West Texas A&M",
    match_str	=> '^(West|W)\.? ?Texas ?A&M$',
  },
  {
    name	=> "West Virginia",
    match_str	=> '^(West|W)\.? ?Virginia$',
  },
  {
    name	=> "Western Carolina",
    match_str	=> '^(West.?rn|West|W)\.? ?Carolina',
  },
  {
    name	=> "Western Illinois",
    match_str	=> '^(West.?rn|West)\.? ?Ill|^W\.? Ill',
  },
  {
    name	=> "Western Kentucky",
    match_str	=> '^(West.?rn|West|W)\.? ?(Kent|Ky)|WKU',
  },
  {
    name	=> "Western Michigan",
    match_str	=> '^(West.?rn|West|W)\.? ?Mich',
  },
  {
    name	=> "William & Mary",
    match_str	=> '^William ?& ?Mary$',
  },
  {
    name	=> "Wisconsin",
    match_str	=> '^Wisconsin$',
  },
  {
    name	=> "Winston-Salem",
    match_str	=> '^(Winston|W).Salem',
  },
  {
    name	=> "Wichita State",
    match_str	=> '^Wichita ?St',
  },
  {
    name	=> "Wofford",
    match_str	=> '^Wofford$',
  },
  {
    name	=> "Wyoming",
    match_str	=> '^Wyoming$',
  },
  {
    name	=> "Xavier",
    match_str	=> '^Xavier$',
  },
  {
    name	=> "Yale",
    match_str	=> '^Yale$',
  },
  {
    name	=> "Youngstown State",
    match_str	=> '^Youngstown ?St',
  },
);

my @names_out;

my $name;
foreach $name (@_) {

#print "LOOKING for $name\n";
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
