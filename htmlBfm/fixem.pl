#!/usr/bin/perl -w

foreach my $file (@ARGV) {

  print "file $file\n";
  #system "mv $file ${file}-mstar";
  open FILE, "<${file}" or die "error opening file ${file} ($!)\n";
  @file = <FILE>;
#  grep s<"http://home.mmcable.com/bassetthq/football.html">
#     <"http://BassettFootball.net">g, @file;
#  grep s<home.mmcable.com/bassetthq>
#     <BassettFootball.net>g, @file;
#  grep s<football.html><index.html>g, @file;
#  grep s</football/><>g, @file;
#  grep s<gbassett\@mmcable.com><Gene\@BassettFootball.net>g, @file;
  grep s<Gene\@BassettFootball.net><bfm\@BassettFootball.net>g, @file;
  close FILE;
  open FILE, ">$file" or die "error opening file $file ($?)\n";
  foreach my $line (@file) {
    print FILE $line;
  }
  close FILE;

}

