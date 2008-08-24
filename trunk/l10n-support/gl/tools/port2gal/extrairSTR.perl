#!/usr/bin/perl -w

$found=0;
while ($line = <STDIN>) {

chomp $line;

  if ( ($line =~ /msgid/) || ($line =~ /msgctxt/) || ($line eq "") || ($line =~ /^\#/) || 
      ($line =~ /Project-Id-Version:/) )   {
      $found=0;
  }

  if ($line =~ /^msgstr/) {
    $line =~ s/msgstr //;
    $found=1;
   # print "$line\n";
  }
  if ($found) {
    print "$line\n";
  }

  

  

}
