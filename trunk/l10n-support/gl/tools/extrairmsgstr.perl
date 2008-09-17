#!/usr/bin/perl -w

$found=0;
while ($line = <STDIN>) {
  chomp $line;

  if ( ($line =~ /msgid/) || ($line=~ /msgctxt/) || ($line eq "") || ($line =~ /^\#/) )   {
     if ($found==1) {print "\n"; $found=0; } else { $found=0; }
  }

  if ($line =~ /^msgstr/) {
    $line =~ s/msgstr //;
    $found=1;
  }

  if ($found) {
    chop $line;
    $inversa = reverse $line;
    chop $inversa;
    $line = reverse $inversa;
    while ($line =~ /<[\/\w\\=,.;:"'\-\ #]*>/) { $line =~ s/<[\/\w\\=,.;:"'\-\ #]*>//g; }
    $line =~ s/&&/and/g;
    $line =~ s/&\w+;/""/eg;
    $line =~ s/&//g;
    print "$line";
  }
}
