#!/usr/bin/perl -w

$found=0;
$buffer="";
while ($line = <STDIN>) {
  chomp $line;

  if ( ($line =~ /msgid/) || ($line=~ /msgctxt/) || ($line eq "") || ($line =~ /^\#/) )   {
     if ($found==1) {
       $buffer =~ s/(<[^>]+>)+//g;
       $buffer =~ s/(&[A-Za-z_:][A-Za-z0-9_\\.:-]*;)+/""/eg;
       $buffer =~ s/&&/and/g;
       $buffer =~ s/&//g;
       print $buffer . "\n";
       $buffer = "";
       $found=0; }
     else { $found=0; }
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
    $buffer = $buffer . $line;
  }
}
