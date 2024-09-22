#! /usr/bin/perl -w

# 2003 optim_bfm.pl
# 2005 optim_bfm_ens.pl

use strict;

$! = 1; # OUTPUT AUTOFLUSH

#my $league = "nfl";
#my $filterid = "IA";
my $league = "colI";
my $filterid = "IA";
# note:
# for finding optimized parameters & cfpool
#my $filterstats = 1;
# for final fit for padj & generating power files for a new season.  Be sure to set most vars in restart to #const.
my $filterstats = 0;
my $sfile_post = "b";
# set only for col:
my $cfpool_db_file = "cfpool_db.txt";

#my $use_restart;
my $use_restart = "optim_restart_ens.txt"; # if defined and exists, then set
                                       # @use_first and @use_vars from it

my $sleep_cool = 0; # bfm
#my $sleep_cool = 3; # tendons
#my $sleep_cool = 1; # gmb3800

# $maximize_var choices: "games", "games_bowl_emphasis3", "cfpool", "weight_percent", "combo_cfpool_percent"
#my $maximize_var = "games_bowl_emphasis3";
#my $maximize_var = "cfpool";
#my $maximize_var = "weight_percent"; 
#my $maximize_var = "combo_cfpool_percent"; 
#my $maximize_var = "rms_winpct_prscore_nocat"; 
#my $maximize_var = "rms_nocat_winpct_skill2_upset"; 
# note: 
#cfpool:
#my $maximize_var = "cfpool_percent"; 
# for finding optimized parameters
#my $maximize_var = "skillmod_rms"; 
# for final fit for padj & generating power files for a new season
my $maximize_var = "skillmodwk"; 

# FIXME - tmp
my $all_def = 1; # 0-use random values (skips restart as well),
                 # 1-use default/initial values (even if @use_first is undef),
                 # 2-use random values but based on vars in restart file

# note:
my $fit_flg = 0;
#cfpool/other search:
#my $fit_flg = 2;
# 0-run once to get home & pwr,
# 1-search for one set of optimum settings, 
# 2-search for optimum settings starting with default values
#   (and repeat with random start values when finished).

my $toler_fact = 0.85; # tolerance = tolerance0 * (toler_fact)^pass

my @use_vars;
my @use_first;
my $pass;
my @num_look = (1,1,1,1,2,3,4,5,6,7,8,9,10,11,12,13);
my @max_iter = (0,0,0,1,2,3,6,10,15,20,25,25,25,25,25,25);

my $restart_version = 0;
if ($use_restart && -s $use_restart && $all_def) {

  open RST, "<$use_restart"
     or die "ERROR opening restart file $use_restart ($!)";
  my @restart = <RST>;
  close RST;
  if ($restart[0] =~ s/^varstr-v(\d+):/varstr:/)
  {
     $restart_version = $1;
  }
  $restart[0] =~ s/^varstr:\s+:?//;
  $restart[0] =~ s/:$//;
  @use_vars = ($restart[0]);
  chomp $restart[1];
  chomp $restart[2];
  $restart[1] =~ s/^left:\s+// if ($restart[1]);
  $restart[2] ||= 0;
  $restart[2] =~ s/^pass:\s+// if ($restart[2]);
  if ($all_def == 1)
  {
    @use_first = split /\s+/, $restart[1] if ($restart[1]);
    $pass = $restart[2];
  }
  else
  {
    $pass = 0;
    @use_first = ();
  }

} else {

  $pass = 0;

  @use_first = ();

# @use_vars = qw(
#   fmix amix fmixl amixl fmixl0 amixl0 mixl_scale nrelax niter
#   mfac thresh wbrfac wbonus homesprd
#   wweight_start_trans wweight_scale
#   odavmx0 odavmxf odavmx_scale
#   cweight1 cweight2 cweight3 mxpnt
#   def_ave off_ave def_new off_new
#   version
#);
#
# Note @use_vars parsing supports restart file syntax, but with = instead of _
# in front of the value.

@use_vars = qw(
  version=2003#const0

  ens_initflg=1%ens1#const1 fitflag=1%ens1#const1
     ens_weight0%ens1#const2 ens_weightf%ens1#const2 ens_weight_scale%ens1#const2
     fmix%ens1#const2 amix%ens1#const2 fmixl0%ens1#const2 amixl%ens1#const2 fmixl0%ens1#const2 amixl0%ens1#const2 mixl_scale%ens1#const2
     nrelax%ens1#const2 niter%ens1#const2
     mxpnt%ens1#const2
     homesprd%ens1#const2
     wweight_start_trans%ens1#const2 wweight_scale%ens1#const2
     odavmx0%ens1#const2 odavmxf%ens1#const2 odavmx_scale%ens1#const2
     cweight1%ens1#const2 cweight2%ens1#const2 cweight3%ens1#const2
     def_ave%ens1#const2 off_ave%ens1#const2 def_new%ens1#const2 off_new%ens1#const2

     ens_initflg%ens2#const1 fitflag%ens2#const1
  ens_weight0%ens2#const2 ens_weightf%ens2#const2 ens_weight_scale%ens2#const2
     fmix%ens2#const2 amix%ens2#const2 fmixl%ens2#const2 amixl%ens2#const2 fmixl0%ens2#const2 amixl0%ens2#const2 mixl_scale%ens2#const2
     nrelax%ens2#const2 niter%ens2#const2
     mxpnt%ens2#const2
     homesprd%ens2#const2
     wweight_start_trans%ens2#const2 wweight_scale%ens2#const2
     odavmx0%ens2#const2 odavmxf%ens2#const2 odavmx_scale%ens2#const2
     cweight1%ens2#const2 cweight2%ens2#const2 cweight3%ens2#const2
     def_ave%ens2#const2 off_ave%ens2#const2 def_new%ens2#const2 off_new%ens2#const2

     ens_initflg=1%begin#const1 fitflag=1%begin#const1
     ens_weight0=100%begin#const1 ens_weightf%begin#const2 ens_weight_scale%begin#const2
     fmix%begin#const2 amix%begin#const2 fmixl%begin#const2 amixl%begin#const2 fmixl0%begin#const2 amixl0%begin#const2 mixl_scale%begin#const2
     nrelax%begin#const2 niter%begin#const2
     mxpnt%begin#const2
     homesprd%begin#const2
     wweight_start_trans%begin#const2 wweight_scale%begin#const2
     odavmx0%begin#const2 odavmxf%begin#const2 odavmx_scale%begin#const2
     cweight1%begin#const2 cweight2%begin#const2 cweight3%begin#const2
     def_ave%begin#const2 off_ave%begin#const2 def_new%begin#const2 off_new%begin#const2

     ens_initflg=1%end#const1 fitflag=1%end#const1
     ens_weight0%end#const2 ens_weightf=100%end#const1 ens_weight_scale%end#const2
     fmix%end#const2 amix%end#const2 fmixl%end#const2 amixl%end#const2 fmixl0%end#const2 amixl0%end#const2 mixl_scale%end#const2
     nrelax%end#const2 niter%end#const2
     mxpnt%end#const2
     homesprd%end#const2
     wweight_start_trans%end#const2 wweight_scale%end#const2
     odavmx0%end#const2 odavmxf%end#const2 odavmx_scale%end#const2
     cweight1%end#const2 cweight2%end#const2 cweight3%end#const2
     def_ave%end#const2 off_ave%end#const2 def_new%end#const2 off_new%end#const2

     ens_initflg=1%changes#const1 fitflag=1%changes#const1
     ens_weight0%changes#const2 ens_weightf%changes#const2 ens_weight_scale%changes#const2
     fmix%changes#const2 amix%changes#const2 fmixl%changes#const2 amixl%changes#const2 fmixl0%changes#const2 amixl0%changes#const2 mixl_scale%changes#const2
     nrelax=4%changes#const1 niter=2%changes#const1
     mxpnt%changes#const2
     homesprd%changes#const2
     wweight_start_trans=1000%changes#const1 wweight_scale=1000%changes#const1
     odavmx0%changes#const2 odavmxf%changes#const2 odavmx_scale%changes#const2
     cweight1%changes#const2 cweight2%changes#const2 cweight3%changes#const2
     def_ave%changes#const2 off_ave%changes#const2 def_new%changes#const2 off_new%changes#const2

  ens_initflg=0%neutral#const1 fitflag=1%neutral#const1
  ens_weight0%neutral#const2 ens_weightf%neutral#const2 ens_weight_scale%neutral#const2
     fmix%neutral#const2 amix%neutral#const2 fmixl%neutral#const2 amixl%neutral#const2 fmixl0%neutral#const2 amixl0%neutral#const2 mixl_scale%neutral#const2
     nrelax%neutral#const2 niter%neutral#const2
     mxpnt%neutral#const2
  homesprd%neutral#const2
  wweight_start_trans%neutral#const2 wweight_scale%neutral#const2
  odavmx0%neutral#const2 odavmxf%neutral#const2 odavmx_scale%neutral#const2
  cweight1%neutral#const2 cweight2%neutral#const2 cweight3%neutral#const2
  def_ave%neutral#const2 off_ave%neutral#const2 def_new%neutral#const2 off_new%neutral#const2

     spd_coef_off#const2 spd_coef_def#const2 tot_coef_0#const2 tot_coef_off#const2 tot_coef_def#const2 rms_coef_0#const2 rms_coef_off#const2 rms_coef_def#const2
     mfac#const2 thresh#const2 wbonus#const2 wbrfac#const2

     padj5#const3 padj6#const3 padj7#const3 padj8#const3 padj9#const3 padj5f#const3 padj6f#const3 padj7f#const3 padj8f#const3 padj9f#const3 padj_scale#const3
     rmsfac#const3

);

die "ERROR: need to have at least one entry in use_vars" unless @use_vars;
#
# NOTE: full list (not including ensemble tag), MUST be included in @def_var_order:
#
# fmix amix fmixl amixl fmixl0 amixl0 mixl_scale nrelax niter
# mfac thresh wbrfac wbonus homesprd
# wweight_start_trans wweight_scale
# odavmx0 odavmxf odavmx_scale
# cweight1 cweight2 cweight3 mxpnt
# def_ave off_ave def_new off_new
# ens_weight0 ens_weightf ens_weight_scale ens_initflg
# version

}

# note:
#cfpool search:
#my @years = qw(1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011); 
# for finding optimized parameters
#my @years = qw(1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011); 
# for final fit for padj & generating power files for a new season (add all past seasons here).  Be sure to set up *b files.
my @years = qw(1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020); 

#my @ens = qw(ens1 ens2 neutral wild);
#my @ens = qw(ens1 ens2 neutral);
my @ens = qw(ens1 ens2 begin end changes neutral);

#my $pwr0_file; # = " colI_1998pwra2";
my %pwr0_file;
#$pwr0_file{ens1} = "colI_1998pwra2";
#$pwr0_file{ens2} = "colI_1998pwra2";

my $bfm_perf_file = "bfm_perf.dat";

my $def_fac = 1.33333;
# moved these into range hash 2003-08-18
#my ($off_ave,$def_ave) = (8,3); # ave off/def
#my ($off_new,$def_new) = (6,1); # ave off/def of new team

my %tolerance = (
  games => 10,
  games_bowl_emphasis3 => 30,
  cfpool => 400,
  weight_percent => 4.0,
  combo_cfpool_percent => 4.0,
  cfpool_percent => 4.0,
  spread_rms => 4,
  rms_winpct_prscore => 4,
  rms_winpct_prscore_nocat => 4,
  rms_nocat_winpct_skill2_upset => 4,
  rms_nocat_winpct_skill3_upset => 4,
  rms_nocat_winpct_skill_upset1 => 4,
  rms_nocat_winpct_skill_upset2 => 4,
  skillmod => 4,
  skillmodwk => 4,
  skillmod_rms => 4,
);
my %precision = (
  games => 0,
  games_bowl_emphasis3 => 0,
  cfpool => 1,
  weight_percent => 0.05,
  combo_cfpool_percent => 0.05,
  cfpool_percent => 0.05,
  spread_rms => 0.05,
  rms_winpct_prscore => 0.05,
  rms_winpct_prscore_nocat => 0.05,
  rms_nocat_winpct_skill2_upset => 0.05,
  rms_nocat_winpct_skill3_upset => 0.05,
  rms_nocat_winpct_skill_upset1 => 0.05,
  rms_nocat_winpct_skill_upset2 => 0.05,
  skillmod => 0.05,
  skillmodwk => 0.05,
  skillmod_rms => 0.05,
);

# $range{param<n>}{max/min/incr/p_scale}
#              or
#                 {values} = "v1 v2 ... vn"
#              also
#                 {description/name} 
my %range = (
#mxpnt    mxpnt
  mxpnt => {
    #values => "3 6 9 12 15 18 21 24 27 30 35 40 45 50 60",
    values => "3 7 14 28 49 72",
#    min => 3,
#    max => 60,
#    incr => 3,
    default => 9,
    p_scale => 10,
    #name => "",
    description => " force a teams predicted vs actual points to be within +-mxpnt of each other",
  },
#homesprd homesprd
  homesprd => {
    min => 2,
    max => 4,
    #incr => 0.1,
    incr => 0.25,
    default => ($league eq "nfl") ? 2.0 : 3.0,
    description => "Home team point advantage",
    p_scale => 1000,
  },
#homenmx  homenmx
  homenmx => {
    min => 200,
    max => 800,
    incr => 50,
    default => 300,
    description => "Maximum number to use when averaging observed  home spread with actual values",
  },
#padj      4.0  0.0  0.0 -5.0 -7.0
  padj5 => {
    min => 0,
    max => 15,
    init_min => 0,
    init_max => 7,
    incr => 0.25,
    default => 4,
    description => "Percentage adjustment to 50% bin",
    p_scale => 1000,
  },
  padj6 => {
    min => -10,
    max => 5,
    init_min => -3,
    init_max => 3,
    incr => 0.25,
    default => 0,
    description => "Percentage adjustment to 60% bin",
    p_scale => 1000,
  },
  padj7 => {
    min => -15,
    max => 5,
    init_min => -3,
    init_max => 3,
    incr => 0.25,
    default => 0,
    description => "Percentage adjustment to 70% bin",
    p_scale => 1000,
  },
  padj8 => {
    min => -15,
    max => 5,
    init_min => -10,
    init_max => 3,
    incr => 0.25,
    default => -5,
    description => "Percentage adjustment to 80% bin",
    p_scale => 1000,
  },
  padj9 => {
    min => -15,
    max => 0,
    init_min => -10,
    init_max => 0,
    incr => 0.25,
    default => -7,
    description => "Percentage adjustment to 90% bin",
    p_scale => 1000,
  },
  padj5f => {
    min => 0,
    max => 10,
    init_min => 0,
    init_max => 7,
    incr => 0.25,
    default => 4,
    description => "Percentage adjustment to 50% bin - final week",
    p_scale => 1000,
  },
  padj6f => {
    min => -10,
    max => 10,
    init_min => -3,
    init_max => 3,
    incr => 0.25,
    default => 0,
    description => "Percentage adjustment to 60% bin - final week",
    p_scale => 1000,
  },
  padj7f => {
    min => -10,
    max => 10,
    init_min => -3,
    init_max => 3,
    incr => 0.25,
    default => 0,
    description => "Percentage adjustment to 70% bin - final week",
    p_scale => 1000,
  },
  padj8f => {
    min => -10,
    max => 10,
    init_min => -10,
    init_max => 3,
    incr => 0.25,
    default => -5,
    description => "Percentage adjustment to 80% bin - final week",
    p_scale => 1000,
  },
  padj9f => {
    min => -10,
    max => 0,
    init_min => -10,
    init_max => 0,
    incr => 0.25,
    default => -7,
    description => "Percentage adjustment to 90% bin - final week",
    p_scale => 1000,
  },
  padj_scale => {
    values => "0.2 0.35 0.5 0.75 1 1.5 2 3 4 6 8",
    #min => 0.2,
    #max => 6,
    #incr => 0.2,
    default => 2,
    description => "length scale for ens_weight: ens_weight0+(ens_weightf-ens_weight0)*(1-e^(wk/ens_weight_scale))",
    p_scale => 100,
  },
#cweights conf_w(1),conf_w(2),conf_w(3)
  cweight1 => {
    min => 0.25,
    max => 3,
    init_min => 1,
    init_max => 1,
    #incr => 0.1,
    incr => 0.25,
    default => 1,
    description => "Weight factor for in conference games",
    p_scale => 1000,
  },
  cweight2 => {
    #values => "0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.75 2 2.25 2.5 3",
    min => 0.25,
    max => 3,
    init_min => 1,
    #incr => 0.1,
    incr => 0.25,
    default => 1,
    description => "Weight factor for non-conference games",
    p_scale => 1000,
  },
  cweight3 => {
    #values => "0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.75 2 2.25 2.5 3",
    min => 0.25,
    max => 3,
    init_min => 1,
    #incr => 0.1,
    incr => 0.25,
    default => 1,
    description => "Weight factor for non-division games",
    p_scale => 1000,
  },
#mix     fmix amix
#mix    0.25 0.30     
  fmix => {
    min => 0.0,
    max => 1.0,
    #incr => 0.05,
    incr => 0.2,
    #default => 0.25,
    default => 0.15,
    description => "Mixing factor to neighbor's values",
    p_scale => 1000,
  },
  amix => {
    min => 0.0,
    max => 1.0,
    #incr => 0.05,
    incr => 0.2,
    #default => 0.3,
    default => 0.4,
    description => "Mixing factor for average value",
    p_scale => 1000,
  },
#mixl     fmixl amixl
#mixl     0.15 0.10
  fmixl => {
    min => 0.0,
    max => 1.0,
    #incr => 0.05,
    incr => 0.2,
    default => 0.15,
    description => "Mixing factor for week 1 to last year's value",
    p_scale => 1000,
  },
  amixl => {
    min => 0.0,
    max => 1.0,
    #incr => 0.05,
    incr => 0.2,
    default => 0.10,
    description => "Mixing factor to last year's value",
    p_scale => 1000,
  },
  fmixl0 => {
    min => 0.0,
    max => 1.0,
    #incr => 0.05,
    incr => 0.2,
    default => 0.15,
    description => "First week's mixing factor for week 1 to last year's value",
    p_scale => 1000,
  },
  amixl0 => {
    min => 0.0,
    max => 1.0,
    #incr => 0.05,
    incr => 0.2,
    default => 0.10,
    description => "First week's mixing factor to last year's value",
    p_scale => 1000,
  },
  mixl_scale => {
    #min => 0,
    #max => 7,
    #incr => 1,
    values => "0 1 2 4 8",
    default => 4,
    description => "Length scale for amixl & fmixl",
    p_scale => 1000,
  },
#nloops   nrelax niter
#nloops   5 15
  nrelax => {
    #values => "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 18 20 22 24 26 28 30",
    values => "1 3 6 10 15 21 30",
    #min => 1,
    #max => 30,
    #incr => 1,
    default => 5,
    description => "Number of relaxation steps per iteration step",
  },
  niter => {
    #values => "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 20 22 24 26 28 30",
    values => "1 3 6 10 15 21 30",
    #min => 1,
    #max => 30,
    #incr => 1,
    default => 15,
    description => "Number of iterations",
  },
#mercy     thresh0 thresh mfac
#mercy    10 24 1.33
#set below: thresh0 = min(max(thresh-14,3),14)
  thresh => {
    #values => "3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 22 24 26 28 30 35 40 60",
    values => "1 3 7 14 28 49 72",
    p_scale => 10,
    default => 10,
    description => "Threshhold for applying full mercy factor",
  },
  mfac => {
    min => 1,
    max => 1.7,
    #incr => 0.05,
    incr => 0.2,
    default => 1.35,
    description => "Mercy factor",
    p_scale => 1000,
  },
#wbonus    wbonus wbrfac
#wbonus   8.5 0.0
  wbonus => {
    min => 0,
    max => 15,
    #incr => 0.5,
    incr => 3,
    default => 8.5,
    description => "Winner's bonus",
    p_scale => 1000,
  },
  wbrfac => {
    min => 0,
    max => 1,
    #incr => 0.1,
    incr => 0.5,
    #default => 0,
    default => 0.5,
    description => "Inital 'real score' guess is  (1-wbrfac)*wbonus ",
    p_scale => 1000,
  },
# rmsfac    rmsfac
  rmsfac => { # does not affect scores, only relative percentages
    min => 0.5,
    max => 10,
    #incr => 0.25,
    incr => 0.5,
    default => 1,
   description => "Factor by which to multiply the score uncertainty before computing probabilities",
    p_scale => 1000,
  },
#  wweights w_wk(0),w_wk(1),w_wk(2),...
#                       - weights (in order of weeks away from target game)
#                         used to average the residuals.  Default is 
#                         3,3,2,1,0,0,...
#wweights 3 2 0.25 0 0 0 0 0 0 0 0
  wweight_scale => {
    values => "0.25 0.5 1 2 5 7.5 10",
    #min => 0.0,
    #max => 10,
    #incr => 0.2,
    #incr => 0.5,
    default => 1,
    description => "length scale  for wweights: e^(-wk/wweight_scale)",
    p_scale => 1000,
  },
  wweight_start_trans => {
    min => 0,
    max => 6,
    #incr => 0.25,
    incr => 1,
    default => 1,
    description => "week value to begin applying scale length transition to 0",
    p_scale => 1000,
  },
#odavemix 0 0.5 0.65 0.7 0.7 0.7 0.7 0.7 0.7 0.7
#  odavemix od_ave_mix(1),od_ave_mix(2),od_ave_mix3(),...
#                       - fraction to mix weeks after last determined
#                         value of off/def with average values.
#                         fraction of 0 (default) uses last value.
#
  odavmx_scale => {
    values => "0.2 0.5 1 2 4",
    #min => 0.2,
    #max => 6,
    #incr => 0.2,
    default => 0.5,
    description => "length scale for odavemix: odavmx0+(odavmxf-odavmx0)*(1-e^(wk/odavmx_scale))",
    p_scale => 1000,
  },
  odavmxf => {
    min => 0,
    max => 1,
    #incr => 0.1,
    incr => 0.2,
    default => 0.6,
    description => "value of odavemax at max week",
    p_scale => 1000,
  },
  odavmx0 => {
    min => 0,
    max => 1,
    #incr => 0.1,
    incr => 0.2,
    #default => 0,
    default => 0.8,
    description => "value of odavemax at week0",
    p_scale => 1000,
  },
  off_ave => {
    min => 7,
    max => 19,
    #incr => 0.2,
    incr => 2,
    default => 13,
    description => "default value of offense to use when no power data available",
    p_scale => 100,
  },
  def_ave => {
    min => 0,
    max => 6,
    #incr => 0.1,
    incr => 1,
    default => 4,
    description => "default value of defense to use when no power data available",
    p_scale => 100,
  },
  off_new => {
    min => 5,
    max => 19,
    #incr => 0.2,
    incr => 2,
    default => 9,
    description => "default value of offense to use power data is available",
    p_scale => 100,
  },
  def_new => {
    min => 0,
    max => 5,
    #incr => 0.1,
    incr => 1,
    default => 2,
    description => "default value of defense to use when power data is available",
    p_scale => 100,
  },
  ens_weight0 => {
    min => 0.0,
    max => 1,
    incr => 0.25,
    default => 1,
    description => "initial week ensemble weight factor",
    p_scale => 100,
  },
  ens_weightf => {
    min => 0.0,
    max => 1,
    incr => 0.25,
    default => 1,
    description => "final ensemble weight factor",
    p_scale => 100,
  },
  ens_weight_scale => {
    values => "0.2 0.5 1 2 4 8",
    #min => 0.2,
    #max => 6,
    #incr => 0.2,
    default => 2,
    description => "length scale for ens_weight: ens_weight0+(ens_weightf-ens_weight0)*(1-e^(wk/ens_weight_scale))",
    p_scale => 100,
  },
  ens_initflg => {
    min => 0,
    max => 1,
    incr => 1,
    default => 1,
    description => "ensemble initflg",
    p_scale => 1,
  },
  version => {
    values => "1999 2001 2003",
    #values => "2003",
    default => 2003,
    description => "bfm version",
    p_scale => 1,
  },
  fitflag => {
    min => 0,
    max => 1,
    incr => 1,
    default => 0,
    description => "traditional-0/linear-1 fit flag",
    p_scale => 1,
  },
  spd_coef_off => {
    min => 0.0,
    max => 20.0,
    incr => 0.2,
    default => 4.84,
    description => "s1 - s2 = spd_coef_off*(o1-d2) + spd_coef_def(o2-d1))",
    p_scale => 1000,
  },
  spd_coef_def => {
    min => 0.0,
    max => 20.0,
    incr => 0.2,
    default => 6.08,
    description => "s1 - s2 = spd_coef_off*(o1-d2) + spd_coef_def(o2-d1))",
    p_scale => 1000,
  },
  tot_coef_0 => {
    min => -30.0,
    max => 30.0,
    incr => 0.2,
    default => -11.18,
    description => "s1 + s2 = tot_coef_0 + tot_coef_off*(o1+d2) + tot_coef_def(o2+d1))",
    p_scale => -1000,
  },
  tot_coef_off => {
    min => 0.0,
    max => 20.0,
    incr => 0.2,
    default => 4.29,
    description => "s1 + s2 = tot_coef_0 + tot_coef_off*(o1+d2) + tot_coef_def(o2+d1))",
    p_scale => 1000,
  },
  tot_coef_def => {
    min => -20.0,
    max => 0.0,
    incr => 0.2,
    default => -4.63,
    description => "s1 + s2 = tot_coef_0 + tot_coef_off*(o1+d2) + tot_coef_def(o2+d1))",
    p_scale => -1000,
  },
  rms_coef_0 => {
    min => 5.0,
    max => 20.0,
    incr => 0.25,
    default => 9.5,
    description => "rms = rms_coef_0 + rms_coef_off*(o1+o2) + rms_coef_def(d1+d2))",
    p_scale => 1000,
  },
  rms_coef_off => {
    min => 0.0,
    max => 2.0,
    incr => 0.05,
    default => 0.2,
    description => "rms = rms_coef_0 + rms_coef_off*(o1+o2) + rms_coef_def(d1+d2))",
    p_scale => 1000,
  },
  rms_coef_def => {
    min => -2.0,
    max => 0.0,
    incr => 0.05,
    default => -0.12,
    description => "rms = rms_coef_0 + rms_coef_off*(o1+o2) + rms_coef_def(d1+d2))",
    p_scale => -1000,
  }
);
#  scrave    sthresh, smax_iter
#                       - sthresh: don't count a score as changed when
#                         averaging if it changes by this amount or less.
#                         smax_iter: stop score averaging if number of
#                         iterations exceed this amount.
#                         NOTE: to disable score averaging, set sthresh<0.

my %bfm_perf;
# $bfm_perf{:p1_v1:p2_v2:...:}{tot_games/bfm_correct/tot_bowl/bfm_bowl/bfm_conf/tot_conf/bfm_nonconf/tot_nonconf/bfm_nondiv/tot_nondiv/tot_wk<n>/bfm_wk<n>/cfpool_tot}
my @def_var_order = qw(
  version
  ens_weight0 ens_weightf ens_weight_scale
  ens_initflg fitflag
  spd_coef_off spd_coef_def tot_coef_0 tot_coef_off tot_coef_def rms_coef_0 rms_coef_off rms_coef_def
  padj5 padj6 padj7 padj8 padj9 padj5f padj6f padj7f padj8f padj9f padj_scale
  mfac thresh wbrfac
  homesprd
  fmix amix fmixl amixl fmixl0 amixl0 mixl_scale
  nrelax niter rmsfac 
  wweight_start_trans wweight_scale
  odavmx0 odavmxf odavmx_scale 
  cweight1 cweight2 cweight3
  mxpnt def_ave off_ave def_new off_new
);
open DATA, "<$bfm_perf_file" or warn "WARNING,  error opening bfm perf file $bfm_perf_file ($!)";
my @perf_in = <DATA>;
close DATA;
while (@perf_in) {
  my $line = shift @perf_in;
  chomp $line;
  if ($line =~ s/^(\S+)\s+//) {
    my $varstr = $1;
    #FIXME - add translation of varstr
    #$varstr =~ s/^:?(.*?):?$/$1/;
    #my %val;
    #my @varstrs =
    my @pairs = split '\s+', $line;
    foreach my $pair (@pairs) {
      my ($key,$val) = split '=', $pair;
      $bfm_perf{$varstr}{$key} = $val;
    }
  } else {
    warn "WARNING, could not parse: $line";
  }
}

my %scores;
# $scores{$year}($week}{$team1}{$team2}{score1/score2/home_flag}
#bdddddhssNbbbhhhhhhhhhhhhhhhhhhhhhhhbbssbbbbaaaaaaaaaaaaaa  -- inputflg = 1
# Se  1 00    Georgia Tech             00 PT Arizona
# FIXME - just need score file name! -  "colI_$year" except for cfpool!
# So far only used to count the number of weeks in each year:
foreach my $year (@years) {
  my $sfile = "${league}_${year}$sfile_post";
  my $week = 0;
  open SCORE, "<$sfile" or die "ERROR opening score file $sfile ($!)";
  my @scores = <SCORE>;
  close SCORE;
  foreach my $game (@scores) {
    chomp $game;
    if ($game =~ /^\S/) {
      $week = sprintf "%0.2d", $week + 1;
    } elsif ($game =~ /^\s(.{5})\s([\s\d]{2})(.)\s{3}(\S.{23})\s{1}([\s\d]{2})\s{4}(\S.*)/) {
# 55555 00    Georgia Tech             00 PT Arizona
# Se 05 21    Mississippi Valley State 38    Arkansas - Pine Bluff
      my ($date_str, $score1, $hmflg, $team1, $score2, $team2) = 
         ($1, $2, $3, $4, $5, $6);
      $score1 += 0;
      $score2 += 0;
      $hmflg =~ s/\s//g;
      $team1 =~ s/\s+$//;
      $team2 =~ s/\s+$//;
      $scores{$year}{$week}{$team1}{$team2}{score1} = $score1;
      $scores{$year}{$week}{$team1}{$team2}{score2} = $score2;
      $scores{$year}{$week}{$team1}{$team2}{home_flag} = $hmflg;
    } else {
      warn "WARNING, could not parse $game";
    }
#bdddddhssNbbbhhhhhhhhhhhhhhhhhhhhhhhbbssbbbbaaaaaaaaaaaaaa  -- inputflg = 1
# Se  1 00    Georgia Tech             00 PT Arizona
  }
}

#FIXME - list needed?
#my %list;
# $list{year}{team}{conference/division}
#foreach my $year (@years) {
#  my $yr = substr($year,2,2);  #FIXME - correct?
#  my $sfile = " colI_list$yr";
#  open LIST, "<$sfile" or die "ERROR opening #list file $sfile ($!)"
#  my @teams = <LIST>;
#  close LIST;
#}

my %cfpool_db;
#      print OUT "$year:$entry:$team_str\t\t:week=".
#         $cfpool_db{$year}{$entry}{"$team_str"}{week}.":winner=".
#         $cfpool_db{$year}{$entry}{"$team_str"}{winner}."\n";
my @db_in;
if ($cfpool_db_file) {
  open DB, "<$cfpool_db_file" 
     or die "ERROR opening CFPOOL file $cfpool_db_file ($!)";
  @db_in = <DB>;
  close DB;
}
foreach my $line (@db_in) {
  chomp $line;
#print "::: db: $line\n";
  if ($line =~ /^(\d{4}):(.*):(.*?):\s*week=(.*):winner=(\d)/) {
    my ($year,$entry,$team_str,$week,$winner) = ($1,$2,$3,$4,$5);
#print "::: year $year entry $entry team_str $team_str week $week winner $winner\n";
    $cfpool_db{$year}{$entry}{$team_str}{week} = $week;
    $cfpool_db{$year}{$entry}{$team_str}{winner} = $winner;
    if ($team_str =~ m|^(.*)/(.*)|) {
      my $team_str2 = "$2/$1";
      $cfpool_db{$year}{$entry}{$team_str2}{week} = $week;
      $cfpool_db{$year}{$entry}{$team_str2}{winner} = 1-$winner;
    } else {
      print "ERROR parsing cfpool team string $team_str ($line)\n";
    }
  }
}

# determine configuration: start params (random and/or fixed), param list to vary (in order)
# FIXME - hardwired to random for now:

my %val;
my %index;

# unpack the variables
if (grep /(:|=|\%|#)/, @use_vars) {
  my @wrk_vars = @use_vars;
  @use_vars = ();
  foreach my $var_str (@wrk_vars) {
    $var_str =~ s/:*$/:/;
    if ($var_str =~ /(:|=)/) {
      while ($var_str =~ s/^:?(.*?)=(-|)([0-9\.]+)(|[%#].*?)(:|\s|$)//) {
        my ($var,$val,$opts) = ($1,$2.$3,$4);
        $opts ||= "";
        my $p_scale = $range{$var}{p_scale} || 1;
        $val = $val/$p_scale if ($restart_version == 0);
        push @use_vars, "$var$opts=$val";
        print "::: unpack var_str into use_vars: var $var val $val opts $opts\n";
      }
      $var_str =~ s/:$//;
      $var_str =~ s/^://;
      if ($var_str =~ /\S/)
      {
        print ":::-1 add to use_vars: var $var_str\n";
        push @use_vars, $var_str;
      }
    } else {
      print ":::-2 add to use_vars: var $var_str\n";
      push @use_vars, $var_str;
    }
  }
}
# Set any default values and mark those which are fixed (constant)

# Filter out which priority of #const to keep.
# note (if not using restart): 
# for finding optimized parameters & cfpool
#grep s/#const[1-9]//, @use_vars;
# for final fit for padj 
grep s/#const[3-9]//, @use_vars;
# trim off number
grep s/#const[0-9]/#const/, @use_vars;

my @iter_vars;

my %fixed_vars;
foreach my $varens (@use_vars) {
  my $fixed = ($varens =~ s/#const//) ? 1 : 0;
  if ($varens =~ s/(.*)=(.*)/$1/) {
    $val{$varens} = $2;
    #next_val($varens, $var,0);
  }
  $fixed_vars{$varens} = $fixed;
  push @iter_vars, $varens if ($fixed == 0);
}

my $continue = 1;
while ($continue) {

#my @vars = @def_var_order;
#FIXME - search only over a specified subset of @def_var_order (and in specified order)

# search over parameters:

my $minscore = -999999;
my $solution = 0;
my $maxscore = $minscore;
my $last_maxscore;

#     next if ($fixed_vars{$varens}); # skip if meant to be constant
#foreach my $var (keys %range) {
my %varens;
foreach my $ve (@use_vars, keys %range)
{
  $varens{$ve} = 1;
}
foreach my $varens (sort keys %varens) {
  my $var = $varens;
  my $ens = "";
  if ($var =~ s/\%(.*)//)
  {
    $ens = $1;
  }
  print "::: varens $varens var $var\n";
  next if ($fixed_vars{$varens} && defined $val{$varens}); # skip if meant to be constant
  print "Assigning value to constant var $varens\n" if ($fixed_vars{$varens});
  if (! $all_def && grep /^$varens$/, @use_vars) {
    print "Assigning value to $varens\n";
    if ($range{$var}{values}) {
      my @values = split ' ', $range{$var}{values};
      $index{$varens} = int(rand(scalar(@values)));
print ":::-index varens $varens index $index{$varens} num-values ".scalar(@values)."\n";
      if (defined $range{$var}{init_min} || defined $range{$var}{init_max}) {
        my $min_val = (defined $range{$var}{init_min})
           ? $range{$var}{init_min} : $values[0];
        my $max_val = (defined $range{$var}{init_max})
           ? $range{$var}{init_max} : $values[$#values];
        while ($values[$index{$varens}] < $min_val 
            || $values[$index{$varens}] > $max_val) {
          print "   var $varens rnd value $values[$index{$varens}] out of range ($min_val to $max_val), retrying ...\n";
          $index{$varens} = int(rand($#values));
          sleep 1; # in case there is a infinite loop
        }
      }
      $val{$varens} = $values[$index{$varens}];
      print "::: var $varens max $#values index $index{$varens} val $val{$varens}\n";
    } else {
      $range{$var}{incr} ||= 1;
      print ":::-range var $var range{$var}{incr} $range{$var}{incr}\n";
      unless (defined $range{$var}{min} && defined $range{$var}{max})
      {
        print "ERROR: can't find a valid min/max for $var: min $range{$var}{min} max $range{$var}{max}\n";
        exit 1;
      }
      my $min_val = (defined $range{$var}{init_min})
         ? $range{$var}{init_min} : $range{$var}{min};
      my $max_val = (defined $range{$var}{init_max})
         ? $range{$var}{init_max} : $range{$var}{max};
      $index{$varens} = int(rand(($max_val-$min_val)/$range{$var}{incr}));
      $val{$varens} = $range{$var}{min} + $range{$var}{incr}*$index{$varens};
      print "::: var $varens max $range{$var}{max} min $range{$var}{min} incr $range{$var}{incr} index $index{$varens} val $val{$varens}\n";
    }
  } else {
    #print "Var $varens (var $var) not found in @use_vars\n";
    print "Var $varens (var $var) not found in use_vars\n";
    $val{$varens} = $range{$var}{default} unless (defined $val{$varens});
    #NOTE: this will reset off-index values!:
    #next_val($ensvar, $var,0); # used for print ::: statement
    print ":::-default var $var varens $varens val $val{$varens}\n";
    unless (defined $val{$varens})
    {
      print "ERROR: Default value undefined for $varens\n";
      exit 1;
    }
  }
}
$all_def = 0;

if ($fit_flg) { # find the the optimum parameters

  until (defined $last_maxscore && abs($last_maxscore - $maxscore) <= $precision{$maximize_var} ) {

    $last_maxscore = $maxscore;

    #foreach my $var (@vars) { #}
    my @vars;
    if (@use_first) {
      @vars = @use_first;
      @use_first = ();
    } else {
      my @tmp_vars = @iter_vars;
      while (@tmp_vars) {
        my $ivar = int(rand($#tmp_vars+1));
      #my $tmp = scalar(@tmp_vars);
      #print "\n::: ivar $ivar #var $#tmp_vars tmp $tmp  vars @tmp_vars\n\n";
        if ($ivar == 0) {
          push @vars, shift @tmp_vars;
        } elsif ($ivar == $#tmp_vars) {
          push @vars, pop @tmp_vars;
        } else {
          push @vars, $tmp_vars[$ivar];
          @tmp_vars = @tmp_vars[0 .. $ivar-1, $ivar+1 .. $#tmp_vars];
        }
      }
    }
    while (@vars) {
      my $varens = shift @vars;
      next if ($fixed_vars{$varens}); # skip if meant to be constant
      my $var = $varens;
      my $ens = "";
      if ($var =~ s/\%(.*)//)
      {
        $ens = $1;
      }
      #print "\n::: var $var  vars left @vars\n\n";
      my $varstr = get_hash_varstr (\%val);
      if ($fit_flg && $use_restart) {
        open RST, ">$use_restart"
           or warn "ERROR opening restart $use_restart ($!)";
        print RST "varstr-v1: $varstr\n";
        print RST "left: $varens";
        if (@vars) {
          print RST " @vars\n";
        } else {
          print RST "\n";
        }
        print RST "pass: $pass\n";
        close RST;
      }

  #goto SKIP; # tmp

      print "Working on $maximize_var varens $varens var $var, starting val $val{$varens} ... ";

      sub intval {
        my ($val,$var,$p_scale) = @_;
        $p_scale ||= 1;
        $val = sprintf "%0.6d", round_it($val*$p_scale);
#       print "::: var $var val $val p_scale $p_scale\n";
        return $val;
      }
      my %score;
      my $intval = intval($val{$varens},$var,$range{$var}{p_scale});
      $score{$intval} = compute_score();
      print "score $score{$intval}\n";
      my $val_at_max = $val{$varens};
      $maxscore = $score{$intval};

      my $tolerance = $tolerance{$maximize_var};
      my $precision = 0.000001 * $precision{$maximize_var} || 0.00000001;
      for (my $p=0; $p<$num_look[$pass]; $p++) {
        $tolerance *= $toler_fact;
      }

      my $mfacstr = (exists $val{"mfac\%$ens"}) ? "mfac\%$ens" : "mfac";

      my ($center_val,$center_score) = 
         ($val{$varens}, $score{$intval});
      my ($right_val, $right_score,$left_val,$left_score);
      my @right_set;
      my @left_set;
      # find max on right until too low (or exceed pass+1 queries)
      my $save_val = $val{$varens};
      my $rmax_found = 0;
      $rmax_found = 1  if ($var eq "thresh" && $val{$mfacstr} == 1);
      my $rmax = $maxscore;
      my $lmax = $maxscore; # do this before $rmax is found
      my $num_right = 0;
      while (defined next_val($varens, $var, 1) && ! $rmax_found && $num_right <= $num_look[$pass]) {
        $num_right += 1;
        $intval = intval($val{$varens},$var,$range{$var}{p_scale});
        $score{$intval} = compute_score();
        push @right_set, "$val{$varens}:$score{$intval}";
        ($right_val,$right_score) = ($val{$varens},$score{$intval})
           unless (defined $right_val);
        print "Looking at $maximize_var var $varens val $val{$varens} (right) score $score{$intval}\n";
        if ($score{$intval} > $maxscore+$precision) {
          $maxscore = $score{$intval};
          $val_at_max = $val{$varens}; 
        }
        $rmax = $score{$intval} if ($score{$intval} > $rmax);
  #print "::: score $score{$intval} var $varens val $val{$varens} max_var $maximize_var toler $tolerance{$maximize_var} rmax $rmax\n";
        $rmax_found = 1 if ($score{$intval} + $tolerance < $rmax);
      }

      # find max on left until too low
      $val{$varens} = $save_val;
      my $lmax_found = 0;
      $lmax_found = 1  if ($var eq "thresh" && $val{$mfacstr} == 1);
      my $num_left = 0;
      while (defined next_val($varens, $var, -1) && ! $lmax_found && $num_left <= $num_look[$pass]) {
        $num_left += 1;
        $intval = intval($val{$varens},$var,$range{$var}{p_scale});
        $score{$intval} = compute_score();
        push @left_set, "$val{$varens}:$score{$intval}";
        ($left_val,$left_score) = ($val{$varens},$score{$intval})
           unless (defined $left_val);
        print "Looking at $maximize_var var $varens val $val{$varens} (left) score $score{$intval}\n";
        if ($score{$intval} > $maxscore+$precision) {
          $maxscore = $score{$intval};
          $val_at_max = $val{$varens}; 
        }
        $lmax = $score{$intval} if ($score{$intval} > $lmax);
        $lmax_found = 1 if ($score{$intval} + $tolerance < $lmax);
      }

      if (! defined $right_score && defined $left_set[1]) {
        if ($left_set[1] =~ /^(.*):(.*)/) {
          ($right_val,$right_score, $center_val,$center_score,
           $left_val,$left_score) = ($center_val,$center_score,
           $left_val,$left_score, $1,$2);
        }
      }
      if (! defined $left_score && defined $right_set[1]) {
        if ($right_set[1] =~ /^(.*):(.*)/) {
          ($left_val,$left_score, $center_val,$center_score,
           $right_val,$right_score) = ($center_val,$center_score,
           $right_val,$right_score, $1,$2);
        }
      }

      # scores too jumpy for this to be of use:
      # estimate the location of the maximum by fitting a parabola 
      # (see notes BFM - find maxiumum score 15 Aug 2003)
#     if ($val_at_max == $center_val && defined $left_val && defined $right_val
#         && $left_val != $center_val && $right_val != $center_val 
#         && $center_score != $right_score && $center_score != $left_score) {
# #print "::: center val $center_val score $center_score  left $left_val score $left_score  right val $right_val score $right_score\n";
#       my $dvr = $right_val - $center_val;
#       my $dvl = $center_val - $left_val;
#       my $dsr = $center_score - $right_score;
#       my $dsl = $center_score - $left_score;
#       my $value = 0.5*$dvr + $center_val
#          - 0.5 * ($dvr + $dvl)/(1 + ($dvr/$dvl)*($dsl/$dsr));
#       # keep it within the precision saved to bfm_perf file
#       my $val0 = $value;
#       my $p_scale = $range{$var}{p_scale} || 1;
#       $value = int(0.5+$value*$p_scale)/$p_scale;
# #      print "::: val0 $val0 value $value p_scale $p_scale\n";
#       if ($value > $left_val && $value < $right_val 
#           && $value != $center_val) {
#         $val{$varens} = $value;
#         $score{$val{$varens}} = compute_score();
#         print "Looking at var $varens val $val{$varens} (parab) score $score{$val{$varens}}\n";
#         if ($score{$val{$varens}} > $maxscore) {
#           $maxscore = $score{$val{$varens}};
#           $val_at_max = $val{$varens}; 
#           print "::: maxima for var $varens located by parabolic method!\n"
#              if ($score{$val{$varens}} == $maxscore);
#         } else {
#           print "WARNING: parabolic method produced non-monotonic value!\n"
#              unless ($score{$val{$varens}} + 0.5*$tolerance
#                    >= $left_score && 
#                 $score{$val{$varens}} + 0.5*$tolerance
#                    >= $right_score);
#           #print "::: parabolic method did not locate a maxima!\n"
#           #   unless ($score{$val{$varens}} == $maxscore);
#         }
#       } else {
#         print "WARNING: parabolic method value out of bounds: left $left_val para $value right $right_val\n" if ($value != $center_val);
#       }
#     }

      # Refine search by looking half way between points with sufficient local
      # variation.
      my $p_scale = $range{$var}{p_scale} || 1;
#     my $max_iter = 1;
#     for (my $i=1; $i<=$pass; $i+=1) {
#       $max_iter += $i;
#     }
      my $max_iter = $max_iter[$pass];
      for (my $iter=0; $iter<$max_iter; $iter+=1) {
        # compute local uncertainty
        my @vals = sort keys %score;
        my $rval = shift @vals;
        my $lval;
        my @uncert;
        my @uval;
        my @umxscr;
        while (@vals) {
          $lval = $rval;
          $rval = shift @vals;
          my $ival = sprintf "%0.6d", int(0.5*($lval+$rval)+0.5);
          my $uncert = 1.5*abs($score{$lval} - $score{$rval});
          push @uncert, $uncert;
          push @uval, $ival;
          if ($score{$lval} > $score{$rval}) {
            push @umxscr, $score{$lval};
          } else {
            push @umxscr, $score{$rval};
          }
        }
        # spread uncertainty from neighbors (but not 
        # if it is zero, neighbor undef, or neighbor maxima is lower than
        # yours [eliminates the case where isolated sharp negative causing
        # multiple neighbors to search]):
        my @uncert2;
        for (my $i=0; $i<=$#uncert; $i+=1) {
          my $li = $i - 1;
          my $ri = $i + 1;
          $uncert2[$i] = $uncert[$i];
          $uncert2[$i] = $uncert[$li] if ($uncert[$i] && defined $uncert[$li] 
             && $uncert[$li] > $uncert[$i] && $umxscr[$i] >= $umxscr[$li]);
          $uncert2[$i] = $uncert[$ri] if ($uncert[$i] && defined $uncert[$ri] 
             && $uncert[$ri] > $uncert[$i] && $umxscr[$i] >= $umxscr[$ri]);
        }
        my @vals = sort keys %score;
        for (my $i=0; $i<=$#uncert2; $i+=1) {
          printf "   Existing iter %d val %s score %s\n",
            $iter,$vals[$i]/$p_scale,$score{$vals[$i]};
          if ($umxscr[$i]+$uncert2[$i] > 
              $maxscore + 0.0000001*$tolerance{$maximize_var}) {
            $val{$varens} = $uval[$i]/$p_scale;
            $score{$uval[$i]} = compute_score();
            printf "Looking at $maximize_var var %s val %s (uncert %d %5.2f+%4.2f) ".
               "score %s\n",$varens,$val{$varens},$iter,$umxscr[$i],$uncert2[$i],
               $score{$uval[$i]};
            if ($score{$uval[$i]} > $maxscore+$precision) {
              $maxscore = $score{$uval[$i]};
              $val_at_max = $val{$varens}; 
            }
          } else {
            printf "   Skipping iter %d val %s ".
               "umxscr+uncert %5.2f+%4.2f=%5.2f\n",
               $iter,$uval[$i]/$p_scale,
               $umxscr[$i],$uncert2[$i],$umxscr[$i]+$uncert2[$i];
          }
        }
        printf "   Existing iter %d val %s score %s\n",
          $iter,$vals[$#vals]/$p_scale,$score{$vals[$#vals]};
      }

      # set val to the one with max score
      $val{$varens} = $val_at_max;

      my $varstr = get_hash_varstr (\%val);
      my $intval = intval($val{$varens},$var,$range{$var}{p_scale});
      print "Choosing $maximize_var var $varens val $val{$varens} score $score{$intval}\n";
      print "   left: @vars\n";

  #    SKIP: ; # tmp
    } # end foreach $varens

    $pass += 1;
    if ($pass > $#num_look)
    {
        push @num_look, $num_look[$#num_look]+1;
        push @max_iter, $max_iter[$#max_iter]+1;
    }

  } # end parameter search

  # FIXME - spiff up
  my $varstr = get_hash_varstr (\%val);
  my $score = compute_score();
  print "MAXIMUM FOUND: $varstr score ($maximize_var) $score\n";
  my $max_str = "$varstr score for $maximize_var = $score";
  print `echo $max_str >> bfm_maxima.txt`;
  if ($use_restart)
  {
    system "head -1 $use_restart >> bfm_maxima.txt";
  }
  print "\n\n\n";

} else { # run one set to get the opt_* files

  push @years, "summary";
  # Get return values from compute_bfm:
  my ($bfm_correct, $bfm_last_wk, $cfpool_score, $spread_rms, $total_score_rms, $catave_spread_rms, $catave_total_score_rms, $prscore, $weight_pct, $upset_factor, $skill, $skill_mod, $skill_mod_wk) = compute_bfm();
  my $score = compute_score();
  my $varstr = get_hash_varstr (\%val);
  print "\nFinished running with parameters: $varstr\n";
  print "   bfm_correct $bfm_correct bfm_last_wk $bfm_last_wk cfpool_score $cfpool_score\n";
  print "   spread_rms $spread_rms total_score_rms $total_score_rms weight_pct $weight_pct\n";
  print "   upset_factor $upset_factor\n";
  print "   skill $skill\n";
  print "   skill_mod $skill_mod\n";
  print "   skill_mod_wk $skill_mod_wk\n";
  print "   catave_spread_rms $catave_spread_rms catave_total_score_rms $catave_total_score_rms prscore $prscore\n";
  print "   score ($maximize_var) $score\n";
  print "See opt_$$ files\n";

}

$continue = 0 if ($fit_flg < 2);
$pass = 0;

} # while ($contiue)

sub next_val {

  my ($varens, $var, $dir) = @_;
  $dir = 1 unless defined ($dir);
  $dir = 1 if ($dir > 0);
  $dir = -1 if ($dir < 0);

  if ($range{$var}{values}) {
    my @values = split ' ', $range{$var}{values};
    if ($val{$varens} <= $values[0]) {
      $index{$varens} = 0;
#print "::: val{$varens} $val{$varens} <= values[0] $values[0]\n";
    } elsif ($val{$varens} >= $values[$#values]) {
      $index{$varens} = $#values;
#print "::: val{$varens} $val{$varens} => values[$#values] $values[$#values]\n";
    } else {
      #$index{$varens} = undef; # FIXME - testing
      if ($dir >= 0) {
        $index{$varens} = $#values;
        for (my $i=0; $i<$#values; $i+=1) {
          if ($val{$varens} < $values[$i+1]) {
            $index{$varens} = $i;
            last;
          }
        }
      } else {
        $index{$varens} = 0;
        for (my $i=$#values; $i>0; $i-=1) {
          if ($val{$varens} > $values[$i-1]) {
            $index{$varens} = $i;
            last;
          }
        }
      }
      #die "ERROR with next_val logic" unless (defined $index{$varens});
    }
    $index{$varens} += $dir;
    if ($index{$varens} < 0) {
      $index{$varens} = 0;
      $val{$varens} = undef;
    } elsif ($index{$varens} > $#values) {
      $index{$varens} = $#values;
      $val{$varens} = undef;
    } else {
      $val{$varens} = $values[$index{$varens}];
    }
#print "::: 534 var $varens val $val{$varens} index{$varens} $index{$varens} dir $dir\n";
  } else {
    $range{$var}{incr} ||= 1;
    my $round = ($dir > 0) ? 0.0000001 : ($dir) ? 0.9999999 : 0.5;
#print "::: var $varens val0 $val{$varens} min $range{$var}{min} incr $range{$var}{incr} round $round\n";
    $index{$varens} = 
       int(($val{$varens}-$range{$var}{min})/$range{$var}{incr}+$round);
#my $indx0 = $index{$varens};
    $index{$varens} += $dir;
    $val{$varens} = $range{$var}{min} + $range{$var}{incr}*$index{$varens};
#print "::: var $varens indx0 $indx0 index $index{$varens} dir $dir val $val{$varens}\n";
    my $maxind = int(($range{$var}{max}-$range{$var}{min})/$range{$var}{incr}+0.0000001);
    if ($index{$varens} < 0) {
      $index{$varens} = 0;
      $val{$varens} = undef;
    } elsif ($index{$varens} > $maxind) {
      $index{$varens} = $maxind;
      $val{$varens} = undef;
    }
  }

  return $val{$varens};

} # end sub next_val

sub compute_score {

  my $varstr = get_hash_varstr (\%val,1);
# if (exists $bfm_perf{$varstr}) { #:::
#   print "VARSTR-$varstr-exists ";
# } else {
#   print "VARSTR-$varstr-computing ";
# }
  compute_bfm() unless (exists $bfm_perf{$varstr});

# $bfm_perf{$varstr}{tot_games} = $bfm_tot_games;
# $bfm_perf{$varstr}{bfm_correct} = $bfm_correct;
# $bfm_perf{$varstr}{tot_bowl} = $bfm_tot_last;
# $bfm_perf{$varstr}{bfm_bowl} = $bfm_last_wk;
# $bfm_perf{$varstr}{tot_conf} = $tot_conf;
# $bfm_perf{$varstr}{bfm_conf} = $bfm_conf;
# $bfm_perf{$varstr}{tot_nonconf} = $tot_nonconf;
# $bfm_perf{$varstr}{bfm_nonconf} = $bfm_nonconf;
# $bfm_perf{$varstr}{tot_nondiv} = $tot_nondiv;
# $bfm_perf{$varstr}{bfm_nondiv} = $bfm_nondiv;
# $bfm_perf{$varstr}{cfpool_tot} = $cfpool_score;

  if ($maximize_var =~ /^games$/) {
    return $bfm_perf{$varstr}{bfm_correct};
  } elsif ($maximize_var =~ /^games_bowl_emphasis3$/) {
    return $bfm_perf{$varstr}{bfm_correct} + 3*$bfm_perf{$varstr}{bfm_bowl};
  } elsif ($maximize_var =~ /^weight_percent$/) {
    return $bfm_perf{$varstr}{weight_pct};
  } elsif ($maximize_var =~ /^combo_cfpool_percent$/) {
    return $bfm_perf{$varstr}{combo_cfp_pct};
  } elsif ($maximize_var =~ /^cfpool$/) {
    return $bfm_perf{$varstr}{cfpool_tot};
  } elsif ($maximize_var =~ /^cfpool_percent$/) {
    return $bfm_perf{$varstr}{cfpool_pct};
  } elsif ($maximize_var =~ /^spread_rms$/) {
    return 100*(10./$bfm_perf{$varstr}{spread_rms} +
           5./$bfm_perf{$varstr}{total_score_rms} +
           0.005*$bfm_perf{$varstr}{weight_pct});
  } elsif ($maximize_var =~ /^rms_winpct_prscore$/) {
    return 34*(10./$bfm_perf{$varstr}{catave_spread_rms}
               + 5./$bfm_perf{$varstr}{catave_total_score_rms})
	 + 33*(0.0001*$bfm_perf{$varstr}{weight_pct})
	 + 33*(1/(1+$bfm_perf{$varstr}{prscore}));
  } elsif ($maximize_var =~ /^rms_winpct_prscore_nocat$/) {
    return 34*(10./$bfm_perf{$varstr}{spread_rms}
               + 5./$bfm_perf{$varstr}{total_score_rms})
	 + 33*(0.0001*$bfm_perf{$varstr}{weight_pct})
	 + 33*(1/(1+$bfm_perf{$varstr}{prscore}));
  } elsif ($maximize_var =~ /^rms_nocat_winpct_skill2_upset$/) {
    return 15*(10./$bfm_perf{$varstr}{spread_rms}
               + 5./$bfm_perf{$varstr}{total_score_rms})
	 + 15*(0.0001*$bfm_perf{$varstr}{weight_pct})
	 + 45*(4*$bfm_perf{$varstr}{skill})
	 + 25*(4*$bfm_perf{$varstr}{upset_factor});
  } elsif ($maximize_var =~ /^rms_nocat_winpct_skill3_upset$/) {
    return 15*(10./$bfm_perf{$varstr}{spread_rms}
               + 5./$bfm_perf{$varstr}{total_score_rms})
	 + 15*(0.0001*$bfm_perf{$varstr}{weight_pct})
	 + 55*(4*$bfm_perf{$varstr}{skill})
	 + 15*(4*$bfm_perf{$varstr}{upset_factor});
  } elsif ($maximize_var =~ /^rms_nocat_winpct_skill_upset1$/) {
    return 12.5*(10./$bfm_perf{$varstr}{spread_rms}
               + 5./$bfm_perf{$varstr}{total_score_rms})
	 + 12.5*(0.0001*$bfm_perf{$varstr}{weight_pct})
	 + 37.5*(4*$bfm_perf{$varstr}{skill})
	 + 37.5*(4*$bfm_perf{$varstr}{upset_factor});
  } elsif ($maximize_var =~ /^rms_nocat_winpct_skill_upset2$/) {
    return 12.5*(10./$bfm_perf{$varstr}{spread_rms}
               + 5./$bfm_perf{$varstr}{total_score_rms})
	 + 12.5*(0.0001*$bfm_perf{$varstr}{weight_pct})
	 + 25*(4*$bfm_perf{$varstr}{skill})
	 + 50*(4*$bfm_perf{$varstr}{upset_factor});
  } elsif ($maximize_var =~ /^skillmod$/) {
    return 100*($bfm_perf{$varstr}{skill_mod});
  } elsif ($maximize_var =~ /^skillmodwk/) {
    return 100*($bfm_perf{$varstr}{skill_mod_wk});
  } elsif ($maximize_var =~ /^skillmod_rms/) {
    return 25*(10./$bfm_perf{$varstr}{spread_rms}
              + 5./$bfm_perf{$varstr}{total_score_rms})
         + 75*($bfm_perf{$varstr}{skill_mod});
  } else {
    die "ERROR: unknown maximize_var $maximize_var";
  }

} # end sub compute_score

sub compute_bfm {

  my ($bfm_correct, $bfm_last_wk, $cfpool_score, $cfpool_perfect);

  my ($bfm_tot_games, $bfm_tot_last);
  my %hist;

  my ($total_score_rms, $filter_spread_rms, $filter_total_score_rms);
  my %total_spread_rms;
  my %total_total_score_rms;
  my %spread_rms_count;
  my ($yrscore, $prscore, $pr2scr, $pr3scr, $score);
  my $score_count = 0;
  my $upset_total = 0;
  my $upset_weight = 0;
  my $upset_prob = 0;
  my $skill = 0;
  my $skill_mod = 0;
  my $skill_mod_wk = 0;
  my (@n_total,@nr_total,@np_total);
  my (@n_total_wk,@nr_total_wk,@np_total_wk);
  my $max_week = 0;

  my %home_field;
  # $home_field{ens}{team}{ave/tot/count}

  my %pwr;
  # $pwr{ens}{team}{off/def}
  foreach my $ens (@ens)
  {
    if (defined $pwr0_file{$ens} && -s $pwr0_file{$ens}) {
      open PWR, "<$pwr0_file{$ens}" or die "ERROR opening pwr0 $ens file $pwr0_file{$ens} ($!)";
      my @pwr_in = <PWR>;
      close PWR;
      foreach my $pwr (@pwr_in) {
  #123456789012345678901234567890123456789012345678
  #Saint Francis - Pennsylv  -0.448+-0.008    3.590+-0.019  -0.450   3.587
        if ($pwr =~ /^(.{24})\s(...\....)\+-.*(...\....)\+-/) {
          my ($team,$def,$off) = ($1,$2,$3);
          $team =~ s/\s+$//;
          $pwr{$ens}{$team}{def} = $def + 0;
          $pwr{$ens}{$team}{off} = $off + 0;
        } else {
          warn "WARNING could not parse pwr line: $pwr";
        }
      }
    }
  } 

  #FIMXE  tmp
  my $fhd = "opt_".$$;

  # Set variable strings (e.g. wweights)

  my %wweights;
  my %odavemix;
  my %thresh0;
  foreach my $ens (@ens)
  {
    #wweights 3 2 0.25 0 0 0 0 0 0 0 0
    for (my $wk=0; $wk<=10; $wk++) {
      my $weight = ($wk < getval("wweight_start_trans",$ens)) ? 1 : exp(-($wk-getval("wweight_start_trans",$ens))/getval("wweight_scale",$ens));
      $wweights{$ens} .= sprintf "%4.3f ", $weight;
    }

    #odavemix 0 0.5 0.65 0.7 0.7 0.7 0.7 0.7 0.7 0.7
    for (my $wk=1; $wk<=10; $wk++) {
      $odavemix{$ens} .= sprintf "%4.3f ", 
         getval("odavmx0",$ens)
         + (getval("odavmxf",$ens)-getval("odavmx0",$ens)) 
         * (1-exp(-$wk/getval("odavmx_scale",$ens)));
    }

    $thresh0{$ens} = getval("thresh",$ens) - 14;
    $thresh0{$ens} = 3 if ($thresh0{$ens} < 3);
    $thresh0{$ens} = getval("thresh",$ens) if ($thresh0{$ens} > getval("thresh",$ens));
    $thresh0{$ens} = 14 if ($thresh0{$ens} > 14);
  }

  ## FIXME - tmp
  # Remove any old ${fhd}* files
  foreach my $file (glob("${fhd}*")) {
    unlink $file or warn "WARNING, error removing file $file";
  }

# my ($off_adj,$def_adj) = (0,0);
  
  #  Loop over year

  foreach my $year (@years)
  {
    my $yr = substr($year,2,2);

    my %pwr_file;
    my %home_file;
    my %def_adj;
    my %off_adj;
    # Create pwr & home files
    foreach my $ens (@ens)
    {
      my ($num, $pwr_tot);
      $pwr_file{$ens} = "${fhd}_${ens}_${year}_pwr";
      open PWR, ">$pwr_file{$ens}" or die "ERROR creating pwr file $pwr_file{$ens} ($!)";
      foreach my $team (sort keys %{$pwr{$ens}}) {
  #123456789012345678901234567890123456789012345678
  #Saint Francis - Pennsylv  -0.448+-0.008    3.590+-0.019  -0.450   3.587
         printf PWR "%-24.24s %7.3f         %7.3f\n", 
            $team, $pwr{$ens}{$team}{def}, $pwr{$ens}{$team}{off};
         $pwr_tot += $pwr{$ens}{$team}{off} + $def_fac*$pwr{$ens}{$team}{def};
         $num += 1;
      }
      close PWR;

      # FIXME - continue
      # FIXME - val{x} -> getval(x,ens)
      # find $def_adj & $off_adj
      $off_adj{$ens} = 0.;
      $def_adj{$ens} = 0.;
      if ($num) {
        $off_adj{$ens} = (getval("off_ave",$ens)
                         + $def_fac*getval("def_ave",$ens)
                         - $pwr_tot/$num)/(1+$def_fac);
        $def_adj{$ens} = $off_adj{$ens}/$def_fac;
      } else {
        warn "WARNING: no power entries found for $year" unless ($year eq $years[0]);
      }

        $home_file{$ens} = "${fhd}_${ens}_${year}_home";
    #   print "Creating home file $home_file\n";
        open HOME, ">$home_file{$ens}"
              or die "ERROR creating home field file $home_file{$ens} ($!)";
        foreach my $team (sort keys %{$home_field{$ens}}) {
    #123456789012345678901234567890
    #Air Force                x
    #  4.6    27.46   6
          printf HOME "%-25.25s%5.1f %8.2f %3d\n",
             $team,
             $home_field{$ens}{$team}{ave},
             $home_field{$ens}{$team}{tot},
             $home_field{$ens}{$team}{count};
        }
        close HOME;
    }

    my @out_files;
    my %out_file_week;

    # Week
    my @weeks = (sort keys %{$scores{$year}});
    push @weeks, "final";
    my $wk0 = 0;
    my $wk;
    my %off0;
    my %def0;
    foreach my $ens (@ens)
    {
      ($off0{$ens},$def0{$ens}) = (getval("off_new",$ens),getval("def_new",$ens));
      if (! (keys %pwr) || $year eq $years[0]) {
        ($off0{$ens},$def0{$ens}) = (getval("off_ave",$ens),getval("def_ave",$ens));
        # skip all but the last "final" week if no power provided
        $wk0 = $#weeks;
        $wk = $weeks[$#weeks-1] + 0;
      }
    }
    #$wk0 += 13; # FIXME - tmp:
    #foreach my $week (@weeks) { #}
    for (my $wkc=$wk0; $wkc<=$#weeks; $wkc+=1) { 
      my $week = $weeks[$wkc];

      $wk = $week + 0  unless ($week eq "final");
         # (otherwise use the last $wk)

#     print "working on $year week $week\n";

      my $predflg = ($week eq "final") ? 0 : 1;

      my $fin = "${fhd}_${year}_${week}.in";
      my $fout = "${fhd}_${year}_${week}.out";
      $out_file_week{$fout} = $week;
      push @out_files, $fout unless ($year =~ /(summary)/);
      open IN, ">$fin" or die "ERROR creating bfm input file $fin ($!)";
      print IN 
"fnmlist  ${league}_list${yr}$sfile_post
fnmsched ${league}_${year}$sfile_post
maxweek  $wk
predflg  $predflg
homenmx  $val{homenmx}
";
      print IN "filterid $filterid\n" if ($filterid);
      print IN "fltrstts $filterstats\n" if ($filterstats);
#     print IN "inputflg 1\npadj      4.0  0.0  0.0 -5.0 -7.0\n\n";
      print IN "inputflg 1\n\n";

      my $padj5 = sprintf "%.6f", getval("padj5","")
                     + (getval("padj5f","")
                     - getval("padj5","")) 
                     * (1-exp(-$wk/getval("padj_scale","")));
      my $padj6 = sprintf "%.6f", getval("padj6","")
                     + (getval("padj6f","")
                     - getval("padj6","")) 
                     * (1-exp(-$wk/getval("padj_scale","")));
      my $padj7 = sprintf "%.6f", getval("padj7","")
                     + (getval("padj7f","")
                     - getval("padj7","")) 
                     * (1-exp(-$wk/getval("padj_scale","")));
      my $padj8 = sprintf "%.6f", getval("padj8","")
                     + (getval("padj8f","")
                     - getval("padj8","")) 
                     * (1-exp(-$wk/getval("padj_scale","")));
      my $padj9 = sprintf "%.6f", getval("padj9","")
                     + (getval("padj9f","")
                     - getval("padj9","")) 
                     * (1-exp(-$wk/getval("padj_scale","")));
      print IN "\npadj      $padj5 $padj6 $padj7 $padj8 $padj9\n";
      print IN "\nrmsfac    ",
		getval("rmsfac",""), "\n";
    
      foreach my $ens (@ens)
      {
        #FIXME - ens cont print ens weight factor ...
        my $mixl_scale = getval("mixl_scale",$ens) || 0.000001;
        my $amixl = getval("amixl0",$ens) 
                  + (getval("amixl",$ens)-getval("amixl0",$ens)) * (1-exp(-$wk/$mixl_scale));
        my $fmixl = getval("fmixl0",$ens) 
                  + (getval("fmixl",$ens)-getval("fmixl0",$ens)) * (1-exp(-$wk/$mixl_scale));
        my $ens_weight = getval("ens_weight0",$ens)
                       + (getval("ens_weightf",$ens)
                       - getval("ens_weight0",$ens)) 
                       * (1-exp(-$wk/getval("ens_weight_scale",$ens)));

        print IN "\n# ensemble $ens\n";
        if (getval("ens_initflg",$ens) == 1 && -s $pwr_file{$ens}) {
          print IN "initflg  1\nfnmpower $pwr_file{$ens}\n";
        } else {
          print IN "initflg  0\n";
        }

        print IN 
"mix      ", getval("fmix",$ens), " ", getval("amix",$ens), "
nloops   ", getval("nrelax",$ens), " ", getval("niter",$ens), "
mxpnt    ", getval("mxpnt",$ens), "
def0off0 $def0{$ens} $off0{$ens}
doadj    $def_adj{$ens} $off_adj{$ens}
mercy    $thresh0{$ens} ", getval("thresh",$ens), " ", getval("mfac",$ens), "
";
        if ($val{version} >= 2003) {
          print IN
"odavemix $odavemix{$ens}
mixl     $fmixl $amixl
wbonus   ", getval("wbonus",$ens), " ", getval("wbrfac",$ens), "
wweights $wweights{$ens}
cweights ", getval("cweight1",$ens), " ", getval("cweight2",$ens), " ", getval("cweight3",$ens), "
fitflag  ", getval("fitflag",$ens), "
fblinear ", getval("spd_coef_off",$ens), " ", getval("spd_coef_def",$ens), " ", getval("tot_coef_0",$ens), " ", getval("tot_coef_off",$ens), " ", getval("tot_coef_def",$ens), " ", getval("rms_coef_0",$ens), " ", getval("rms_coef_off",$ens), " ", getval("rms_coef_def",$ens), "
";
        }
        print IN "homefile $home_file{$ens}\n" if (-s $home_file{$ens});
        print IN 
"homesprd ", getval("homesprd",$ens), "
complast 1
";
        if ($ens eq $ens[$#ens])
        {
          print IN "lastens  $ens_weight\n";
        }
        else
        {
          print IN "ensemble $ens_weight\n";
        }
      }

      close IN;

      
#     print "  running bfm for year $year week $week\n";
      ##FIXME - tmp
      my $varstr = get_hash_varstr (\%val,1);
      my $tag_file = "opt_tag_${year}_${week}";
      my $skip =0;
      my ($tag_varstr,$out_file);
      if (-s $tag_file)
      {
        ($tag_varstr,$out_file) = `cat $tag_file`;
        chomp ($tag_varstr);
        chomp ($out_file);
        $skip = 1 if ($tag_varstr eq $varstr && -s $out_file);
      }

      if ($skip)
      {
        my $cp_cmd = "cp $out_file $fout";
        print "copy pre-computed results: $cp_cmd\n";
        print `$cp_cmd`;
      }
      else
      {  
        print "running for $fin\n";
        my $bfm_stat;
        $bfm_stat = system "../bin/bfm$val{version} < $fin > $fout" unless ($fin =~ /summary/);

        if ($bfm_stat)
        {
          warn "ERROR running ../bin/bfm$val{version}: $bfm_stat ($?)";
        }
        else
        {
          print `echo "$varstr" > $tag_file`;
          print `echo $fout >> $tag_file`;
        }

        if ($sleep_cool)
        {
          print "sleeping $sleep_cool sec for cooldown\n";
          sleep $sleep_cool;
        }

      }

    } # end $wk

    next unless @out_files; # won't have output if $year = "summary"

    # Update pwr & home data

    # don't reset power, rather keep old value if a team comes back 
    #%pwr = ();
    # but keep in mind $def_adj & $off_adj drift!

    my $fout = pop @out_files;
    open OUT, "<$fout" or die "ERROR opening end season output file $fout ($!)";
    my @final_out = <OUT>;
    close OUT;
    my $first_team;
    my $enscnt = -1;
    my $first_team2;
    my $enscnt2 = -1;
    foreach my $line (@final_out) {
      chomp $line;
      
#print "::: pwr line: $line\n" if ($line =~ /^(......)\+-.*(......)\+-/);
     if ($line =~ /^(.{24})\s(...\....)\+-.*(...\....)\+-/) {
        my ($team,$def,$off) = ($1,$2,$3);
        $team =~ s/\s+$//;
        $first_team = $team unless (defined $first_team);
        $enscnt += 1 if ($team eq $first_team);
        $pwr{$ens[$enscnt]}{$team}{def} = $def + 0;
        $pwr{$ens[$enscnt]}{$team}{off} = $off + 0;
#       print "pwr: team $team off $off def $def\n";
#123456789012345678901234567890123456789012345678
#Saint Francis - Pennsylv  -0.448+-0.008    3.590+-0.019  -0.450   3.587
      } elsif ($line =~ /^home: (.{25})(..\d\.\d) (....\d\...) (..\d)\b/) {
        my ($team,$ave,$tot,$count) = ($1,$2,$3,$4);
        $team =~ s/\s+$//;
        $first_team2 = $team unless (defined $first_team2);
        $enscnt2 += 1 if ($team eq $first_team2);
        $home_field{$ens[$enscnt]}{$team}{tot} += $tot;
        $home_field{$ens[$enscnt]}{$team}{count} += $count;
        $home_field{$ens[$enscnt]}{$team}{ave} = 
             ($home_field{$ens[$enscnt]}{$team}{count}) 
            ? $home_field{$ens[$enscnt]}{$team}{tot}
             /$home_field{$ens[$enscnt]}{$team}{count}
            : 0;
#       print "home: team $team tot $tot count ".$home_field{$team}{count}."\n";
      }
    }

    #   extract data & results - year subtotals

    # FIXME - does the output change with ensembles?
    my %pred_scores;
    my $correct_last = 0;
    my ($num_games,$num_correct);
    foreach my $fout (@out_files) {
      my $week = $out_file_week{$fout};
      $max_week = $week if ($week > $max_week);
#     print "::: fout $fout\n";
      open OUT, "<$fout" or 
         die "ERROR opening end season output file $fout ($!)";
      my @out = <OUT>;
      close OUT;
      $week = sprintf "%0.2d", $week;
      foreach my $line (@out) {
        chomp $line;
        if ($line =~ /^pred2:(..)\%.(.\d\.\d) ... (\S.{23})(..\d\.\d), ..... (\S.{23})(..\d\.\d)/ ) {
          my ($prob,$spread,$team1,$spred1,$team2,$spred2) = 
             ($1,$2,$3,$4,$5,$6);
          my $sort_str = 
             sprintf "%0.2d%0.3d%s%s", $prob, $spread*10+30, $team1, $team2;
          $team1 =~ s/\s+$//;
          $team2 =~ s/\s+$//;
          $pred_scores{$week}{"$team1/$team2"} = $sort_str;
#print "::: pred_scores $week team_str $team1/$team2 sort_str $sort_str\n";
        } elsif ($line =~ /^(|conf|nonconf|nondiv) ?result hist .n,nr,np.:\s*(\S+)\s+(\S+)\s+(\S+)/) {
#result hist (n,nr,np): 35 27.0 26.63  2  0.0  1.12  9  7.0  5.76  8  8.0  6.06 15 11.0 12.77  1  1.0  0.92  0  0.0  0.00
# total, 50%s, 60%s, ... 100%s
#         print "::: result hist: $line\n";
          my ($type,$num_tgames,$num_tcorrect) = ($1,$2,$3);
          if (! $type) {
            $num_correct = $num_tcorrect;
            $num_games = $num_tgames;
            $correct_last = $num_correct; # number correct for last week (bowls) - see $bfm_last_wk below
            $bfm_correct += $num_correct;
            $bfm_tot_games += $num_games;
          } else {
#           print "::: type $type correct $num_tcorrect total $num_tgames\n";
            $hist{"bfm_$type"} += $num_tcorrect;
            $hist{"tot_$type"} += $num_tgames;
          }
        } elsif ($line =~ /^\s*act-pred filtered spread,total,n rms:\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
          my ($spread_conf, $total_conf, $count_conf) = ($1, $2, $3);
          my ($spread_nonconf, $total_nonconf, $count_nonconf) = ($4, $5, $6);
          my ($spread_nondiv, $total_nondiv, $count_nondiv) = ($7, $8, $9);
          $spread_conf = 100 if ($spread_conf =~ /nan/i);
          $total_conf = 100 if ($total_conf =~ /nan/i);
          $spread_nonconf = 100 if ($spread_nonconf =~ /nan/i);
          $total_nonconf = 100 if ($total_nonconf =~ /nan/i);
          $spread_nondiv = 100 if ($spread_nondiv =~ /nan/i);
          $total_nondiv = 100 if ($total_nondiv =~ /nan/i);
          $total_spread_rms{conf} += $count_conf*$spread_conf*$spread_conf;
          $total_spread_rms{nonconf} += $count_nonconf*$spread_nonconf*$spread_nonconf;
          $total_spread_rms{nondiv} += $count_nondiv*$spread_nondiv*$spread_nondiv;
          $total_total_score_rms{conf} += $count_conf*$total_conf*$total_conf;
          $total_total_score_rms{nonconf} += $count_nonconf*$total_nonconf*$total_nonconf;
          $total_total_score_rms{nondiv} += $count_nondiv*$total_nondiv*$total_nondiv;
          $spread_rms_count{conf} += $count_conf;
          $spread_rms_count{nonconf} += $count_nonconf;
          $spread_rms_count{nondiv} += $count_nondiv;
#         $total_spread_rms += $spread_rms if ($spread_rms !~ /nan/i);
#         $total_total_score_rms += $total_score_rms if ($total_score_rms !~ /nan/i);
#         $spread_rms_count += 1 if ($spread_rms !~ /nan/i);
        } elsif ($line =~ /score:\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
          my ($yrscore_in, $prscore_in, $pr2scr_in, $pr3scr_in, $score_in) = ($1, $2, $3, $4, $5);
          $yrscore += $yrscore_in;
	  $prscore += $prscore_in;
	  $pr2scr += $pr2scr_in;
	  $pr3scr += $pr3scr_in;
	  $score += $score_in;
	  $score_count += 1;
        } elsif ($line =~ /^upset_factor.*:\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
          $upset_total += $2;
          $upset_weight += $3;
          $upset_prob += $4;
        } elsif ($line =~ /^\s*filtered result hist .*:\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
          my (@n,@nr,@np, @skill_adjust);
          my ($ntot, $nrtot, $nptot);
          ($ntot, $nrtot, $nptot, $n[5], $nr[5], $np[5], $n[6], $nr[6], $np[6], $n[7], $nr[7], $np[7], $n[8], $nr[8], $np[8], $n[9], $nr[9], $np[9]) = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18);
          for (my $ip=5; $ip<10; $ip+=1)
          {
            $n_total[$ip] += $n[$ip];
            $nr_total[$ip] += $nr[$ip];
            $np_total[$ip] += $np[$ip];
            $n_total_wk[$ip-5+$week*5] += $n[$ip];
            $nr_total_wk[$ip-5+$week*5] += $nr[$ip];
            $np_total_wk[$ip-5+$week*5] += $np[$ip];
          }
        }
      }
    }
    $bfm_last_wk += $correct_last if (defined $correct_last);
    $bfm_tot_last += $num_games if (defined $num_games);

    # compute CFPOOL score

    my $entry_score;
    foreach my $entry (sort keys %{$cfpool_db{$year}}) {
#print "::: cfpool entry $entry\n";
      my $tot_raw = 0;
      my $raw = 1;
      my %entry;
      my $num_entries = 0;
      $entry_score = 0;
      foreach my $team_str (keys %{$cfpool_db{$year}{$entry}}) {
        $num_entries += 1;
        # remember since $team1/$team2 AND $team2/$team1 are both in 
        # in the database, it is not necessary to reverse team_str
        my $week = sprintf "%0.2d",
           $cfpool_db{$year}{$entry}{"$team_str"}{week};
#print "::: cfpool year $year entry $entry team_str $team_str week $week\n";
        if (exists $pred_scores{$week}{$team_str}) {
          $num_games += 1;
          $tot_raw += $raw;
          $raw *= 1.1;
          my $prob_sort_str = $pred_scores{$week}{$team_str};
          $entry{$prob_sort_str} = 
             $cfpool_db{$year}{$entry}{$team_str}{winner};
#print ":::   prob_sort_str $prob_sort_str winner $entry{$prob_sort_str}\n";
        }
      }
      my $score_val = ($tot_raw) ? 1000/$tot_raw : 0;
#print "::: score_val $score_val\n";
      foreach my $prob_sort_str (sort keys %entry) {
        $entry_score += $entry{"$prob_sort_str"} * $score_val;
#print ":::   str $prob_sort_str entry $entry{$prob_sort_str} val $score_val\n";
        $score_val *= 1.1;
      }
      if ($cfpool_db_file) {
#       print "cfpool year $year entry $entry score $entry_score\n";
        $cfpool_score += $entry_score; # add this entry's score to total score
        $cfpool_perfect += 1000 if ($entry_score);
        if ($num_entries >= 20) # bowl entries count double
        {
          $cfpool_score += $entry_score; # add this entry's score to total score
          $cfpool_perfect += 1000 if ($entry_score);
        }
      }
      else
      {
        $cfpool_score += 0;
      }
    }
#   if ($cfpool_db_file) {
#     $cfpool_score += $entry_score if ($entry_score); # last entry of year counts double
#     $cfpool_perfect += 1000 if ($entry_score);
#     print "cfpool score after year $year is $cfpool_score\n";
#   }

  } # end $year

  # Write out (i.e. update) solution hash (including histograms? & cfpool results)
  my $varstr = get_hash_varstr (\%val,1);
  $bfm_perf{$varstr}{tot_games} = $bfm_tot_games;
  $bfm_perf{$varstr}{bfm_correct} = $bfm_correct;
  $bfm_perf{$varstr}{tot_bowl} = $bfm_tot_last;
  $bfm_perf{$varstr}{bfm_bowl} = $bfm_last_wk;
  $bfm_perf{$varstr}{tot_conf} = $hist{tot_conf};
  $bfm_perf{$varstr}{bfm_conf} = $hist{bfm_conf};
  $bfm_perf{$varstr}{tot_nonconf} = $hist{tot_nonconf};
  $bfm_perf{$varstr}{bfm_nonconf} = $hist{bfm_nonconf};
  $bfm_perf{$varstr}{tot_nondiv} = $hist{tot_nondiv};
  $bfm_perf{$varstr}{bfm_nondiv} = $hist{bfm_nondiv};
  $score_count = 1 if ($score_count == 0);
  $bfm_perf{$varstr}{prscore} = $prscore/$score_count;
  $bfm_perf{$varstr}{yrscore} = $yrscore/$score_count;
  $bfm_perf{$varstr}{spread_rms} = 0;
  $bfm_perf{$varstr}{total_score_rms} = 0;
  my $count_rms = 0;
  my $cat_count = 0;
  $bfm_perf{$varstr}{catave_spread_rms} = 0;
  $bfm_perf{$varstr}{catave_total_score_rms} = 0;
  $bfm_perf{$varstr}{upset_factor} = 0;
  foreach my $cat (qw(conf nonconf nondiv))
  {
    $count_rms += $spread_rms_count{$cat};
    $bfm_perf{$varstr}{spread_rms} += $total_spread_rms{$cat};
    $bfm_perf{$varstr}{total_score_rms} += $total_total_score_rms{$cat};
    if (defined $spread_rms_count{$cat} && $spread_rms_count{$cat} > 0)
    {
      $total_spread_rms{$cat} = sqrt($total_spread_rms{$cat}/$spread_rms_count{$cat});
      $total_total_score_rms{$cat} = sqrt($total_total_score_rms{$cat}/$spread_rms_count{$cat});
      $bfm_perf{$varstr}{catave_spread_rms} += $total_spread_rms{$cat}*$total_spread_rms{$cat};
      $bfm_perf{$varstr}{catave_total_score_rms} += $total_total_score_rms{$cat}*$total_total_score_rms{$cat};
      $cat_count += 1;
    }
    else
    {
      $total_spread_rms{$cat} = 0;
      $total_total_score_rms{$cat} = 0;
    }
  }
  if ($count_rms > 0)
  {
    $bfm_perf{$varstr}{spread_rms} = sqrt($bfm_perf{$varstr}{spread_rms}/$count_rms);
    $bfm_perf{$varstr}{total_score_rms} = sqrt($bfm_perf{$varstr}{total_score_rms}/$count_rms);
  }
  $cat_count = 1 unless ($cat_count > 0);
  $bfm_perf{$varstr}{catave_spread_rms} = sqrt($bfm_perf{$varstr}{catave_spread_rms}/$cat_count);
  $bfm_perf{$varstr}{catave_total_score_rms} = sqrt($bfm_perf{$varstr}{catave_total_score_rms}/$cat_count);
  if ($cfpool_db_file) {
    $bfm_perf{$varstr}{cfpool_tot} = $cfpool_score;
    if ($cfpool_perfect)
    {
      $bfm_perf{$varstr}{cfpool_pct} = 100 * $cfpool_score/$cfpool_perfect;
    }
    else
    {
      $bfm_perf{$varstr}{cfpool_pct} = 0;
    }
  }
  my ($min_tot,$count,$sum_pct) = (5,0,0);
  foreach my $class (qw(conf nonconf nondiv bowl)) {
    if ($bfm_perf{$varstr}{"tot_$class"} > $min_tot) {
      $count += 1;
      $sum_pct +=
         $bfm_perf{$varstr}{"bfm_$class"}/$bfm_perf{$varstr}{"tot_$class"};
    }
  }
  $bfm_perf{$varstr}{weight_pct} = ($count) ? 100*$sum_pct/$count : 0;
  if ($cfpool_db_file) {
    $bfm_perf{$varstr}{combo_cfp_pct} = 
       0.5*($bfm_perf{$varstr}{cfpool_pct} + $bfm_perf{$varstr}{weight_pct});
  }
  my $expected_upset = ($upset_weight > 0) ? $upset_total/$upset_prob : 1;
  $bfm_perf{$varstr}{upset_factor} = ($upset_weight > 0) ? $upset_total/$upset_weight : 0;
  # Penalize upset_factor if expected_upset is not at 1 (forecast probabilities not matching actual results)
  if ($expected_upset > 1)
  {
    $expected_upset = 2 - $expected_upset;
    $expected_upset = 0 if ($expected_upset < 0);
  }
  print "::: Expected upset $expected_upset\n";
  $bfm_perf{$varstr}{upset_factor} *= $expected_upset;
  my $total_games = 0;
  for (my $ip=5; $ip<10; $ip+=1)
  {
    $total_games += $n_total[$ip];
    my $adjust = ($nr_total[$ip] - $np_total[$ip]);
    $adjust /= $n_total[$ip] if ($n_total[$ip] > 0);
    $adjust = -$adjust if ($adjust < 0);
    my $adjust_mod = $adjust;
    $adjust_mod = 1 - $adjust_mod;
    $adjust_mod = 0 if ($adjust_mod < 0);
    $adjust *= 10; # No credit for errors > 10 %
    $adjust = 1 - $adjust;
    $adjust = 0 if ($adjust < 0);
#   print "::: i $ip n $n_total[$ip] nr $nr_total[$ip] np $np_total[$ip] a $adjust -> $nr_total[$ip]*$adjust\n";
    $skill += $nr_total[$ip]*$adjust;
    $skill_mod += $nr_total[$ip]*$adjust_mod;
    my $nr_total_adjust_mod = 0;
    for (my $wk=0; $wk<=$max_week; $wk+=1)
    {
        # get rid of undefs
        $n_total_wk[$ip-5+$wk*5] += 0;
        $nr_total_wk[$ip-5+$wk*5] += 0;
        $np_total_wk[$ip-5+$wk*5] += 0;
        my $adjust_wk = ($nr_total_wk[$ip-5+$wk*5] - $np_total_wk[$ip-5+$wk*5]);
        $adjust_wk /= $n_total_wk[$ip-5+$wk*5] if ($n_total_wk[$ip-5+$wk*5] > 0);
        $adjust_wk = -$adjust_wk if ($adjust_wk < 0);
        my $adjust_mod_wk = $adjust_wk;
        $adjust_mod_wk = 1 - $adjust_mod_wk;
        $adjust_mod_wk = 0 if ($adjust_mod_wk < 0);
        #$adjust_wk *= 10; # No credit for errors > 10 %
        #$adjust_wk = 1 - $adjust_wk;
        #$adjust_wk = 0 if ($adjust_wk < 0);
        $skill_mod_wk += $nr_total_wk[$ip-5+$wk*5]*$adjust_mod_wk;
        $nr_total_adjust_mod += $nr_total_wk[$ip-5+$wk*5]*$adjust_mod_wk;
    }
    print "::: i $ip n $n_total[$ip] nr $nr_total[$ip] np $np_total[$ip] a $adjust_mod -> $nr_total[$ip]*$adjust_mod -> wk $nr_total_adjust_mod\n";
  }
  $skill *= ($total_games > 0) ? 1./$total_games : 1;
  $skill_mod *= ($total_games > 0) ? 1./$total_games : 1;
  $skill_mod_wk *= ($total_games > 0) ? 1./$total_games : 1;
  $bfm_perf{$varstr}{skill} = $skill;
  $bfm_perf{$varstr}{skill_mod} = $skill_mod;
  $bfm_perf{$varstr}{skill_mod_wk} = $skill_mod_wk;
  #my $outstr = "$varstr tot_games=$bfm_tot_games bfm_correct=$bfm_correct tot_bowl=$bfm_tot_last bfm_bowl=$bfm_last_wk cfpool_tot=$cfpool_score";
  my $outstr = $varstr;
  foreach my $key (sort keys %{$bfm_perf{$varstr}}) {
    $outstr .= " $key=$bfm_perf{$varstr}{$key}";
  }
  open DATA, ">>$bfm_perf_file" or warn "WARNING,  error appending to bfm perf file $bfm_perf_file ($!)";
  print DATA "$outstr\n";
#  print "Writing to data base: $outstr\n";
  close DATA;

  # Return results from compute_bfm:
  return ($bfm_correct, $bfm_last_wk, $cfpool_score, 
      $bfm_perf{$varstr}{spread_rms}, $bfm_perf{$varstr}{total_score_rms}, 
      $bfm_perf{$varstr}{catave_spread_rms},
      $bfm_perf{$varstr}{catave_total_score_rms},
      $bfm_perf{$varstr}{prscore},
      $bfm_perf{$varstr}{weight_pct},
      $bfm_perf{$varstr}{upset_factor},
      $bfm_perf{$varstr}{skill},
      $bfm_perf{$varstr}{skill_mod},
      $bfm_perf{$varstr}{skill_mod_wk}
  )
} # end sub compute_bfm

# Get the value for variable $var and ensemble $ens
sub getval
{
  my ($var, $ens) = @_;
  if (exists $val{"$var\%$ens"})
  {
    return $val{"$var\%$ens"};
  }
  else
  {
    return $val{$var};
  }
}

sub round_it {
  my $value = shift @_;
  if ($value >= 0)
  {
    return int($value+0.5);
  }
  else
  {
    return -int(-$value+0.5);
  }
}

sub get_hash_varstr {
  my ($val,$sort_flag) = @_;
  if ($sort_flag)
  {
    my @ens_strs;
    foreach my $ens (@ens)
    {
      my $varstr = ":";
      foreach my $var (@def_var_order) {
        my $p_scale = $range{$var}{p_scale} || 1;
        my $value = getval($var,$ens);
        #$varstr .= sprintf "%s=%0.1d", $var, round_it(getval($var,$ens)*$p_scale);
        $varstr .= sprintf "%s=%s", $var, getval($var,$ens);
        if (!defined $value || !defined $var || !defined $ens || !defined $p_scale)
        {
          print "ERROR: undefined element in varstr $varstr var $var p_scale $p_scale value $value ens $ens\n";
          exit 1;
        }
        $varstr .= ":";
      }
      push @ens_strs, $varstr;
    }
    my $sorted = join '::', sort @ens_strs;
    return $sorted;
  }
  else
  {
    my $varstr = ":";
    foreach my $varens (@use_vars)
    {
      my $ens = "";
      my $var = $varens;
      $var =~ s/#const//; # just in case
      if ($var =~ s/\%(.*)//)
      {
        $ens = $1;
      }
      my $p_scale = $range{$var}{p_scale} || 1;
#     print "::: var $var ens $ens p_scale $p_scale\n";
      #$varstr .= sprintf "%s=%0.1d", $var, round_it(getval($var,$ens)*$p_scale);
      $varstr .= sprintf "%s=%s", $var, getval($var,$ens);
      $varstr .= "\%$ens" if ($ens);
      $varstr .= "#const" if ($fixed_vars{$varens});
      $varstr .= ":";
    }
    return $varstr;
  }
}
