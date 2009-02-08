#!/usr/bin/perl -w
# Usage: extrairmsgstr.perl < file.po
# Purpose: get each translated text in a single line
# Copyright (c) 2008, Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of the Marcelino Villarino Aguiar nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

$utnr=0;
$found=0;
$buffer="";
while ($line = <STDIN>) {
  chomp $line;

  if ( ($line =~ /^msgid/) || ($line=~ /^msgctxt/) || ($line eq "") || ($line =~ /^\#/) )   {
     if ($found == 1) {
#       $buffer =~ s/(<[^>]+>)+//g;
#       $buffer =~ s/(&[A-Za-z_:][A-Za-z0-9_\\.:-]*;)+/""/eg;
#       $buffer =~ s/&&/and/g;
#       $buffer =~ s/&//g;
       if ($utnr > 1) { print $buffer . "\n";}
       $buffer = "";
       $found=0; }
     else { $found=0; }
  }

  if ($line =~ /^msgstr/) {
    $line =~ s/msgstr //;
    $found = 1;
    $utnr += 1;
  }

  if ($found) {
    chop $line;
    $inversa = reverse $line;
    chop $inversa;
    $line = reverse $inversa;
    $buffer = $buffer . $line;
  }
}
