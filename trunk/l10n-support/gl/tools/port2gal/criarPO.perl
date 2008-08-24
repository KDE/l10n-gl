#!/usr/bin/perl -w


use locale;
use POSIX;

setlocale(LC_CTYPE,"pt_PT");

$file1 = shift(@ARGV);
open (FILE1, $file1) or die "O ficheiro n�o pode ser aberto: $!\n";


$i=0;
while ($str = <FILE1>) {
  chomp $str; 
  $i++;
  $Str[$i] = $str;
  
}



print STDERR "num. de msgstr: #$i#\n";

$i=1;
$found=0;
while ($line = <>) {
  chomp $line; 
  if ( ($line =~ /msgid/) || ($line=~ /msgctxt/) || ($line eq "") || ($line =~ /^\#/) || 
      ($line =~ /Project-Id-Version:/) )   {
      $found=0;
  }

  if ($found) {
   
    $line = "$Str[$i]" ;
    $i++;
  }

  if ($line =~ /^msgstr/) {
      
      $line = "msgstr $Str[$i]" ;
      $i++;
      $found=1;
  }

  
        
  print "$line\n";
  
 
}

print STDERR "$i\n";  

  
