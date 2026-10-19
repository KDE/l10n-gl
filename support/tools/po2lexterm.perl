#!/usr/bin/perl -w
#Este script serve para extrair os textos orixe dun ficheiro po/pot.
#Pon cada msgid nunha só liña. Adicionalmente, elimina os atallos de teclado (&) e entidades xml (&algo;) e tamén os et (&&).
#De xeito incompleto, retira as etiquetas html.
#Utilización: cat ficheiro.po | [rota ao script]/extrairmsgid.perl > ficheirosaida.txt
#Este script é unha adaptación dun ficheiro de script que formaba parte do paquete port2gal.
# Copyright (c) 2008, Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of the Marcelino Villarino Aguiar nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Usage: perl po2lexterm.perl file.po 

sub publish {
  $_[0] =~ s/(<[^>]+>)+//g;
  $_[0] =~ s/(&[A-Za-z_:][A-Za-z0-9_\\.:-]*;)+/""/eg;
  $_[0] =~ s/&&/and/g;
  $_[0] =~ s/&//g;
  $_[0] =~ s/\\\"/\"/g;
  $_[0] =~ s/\\n/ /g;
  print $_[0];
}

$found=0;
$buffer="";

open(FILE, $ARGV[0]) || die("Could not open file!");
@raw_data=<FILE>;
close(FILE);
foreach $line (@raw_data) {
  chomp $line;
#found = 1 if in msgid
#found = 2 if in msgstr
#found = 0 otherwise

# if not in an interesting area but where, publish text and declare we are not in an interesting one.  
  if ( ($line eq "") || ($line =~ /^\#/) || ($line=~ /^msgctxt/) )   { if ($found) {$buffer = $buffer . "\n"; publish($buffer); $buffer="";} $found=0;}

# process msgid
  if ($line =~/^msgid_plural/) {
      $found=0; #discard plural message
  }

  if ($line =~ /^msgid/) {
    $line =~ s/msgid //;
    $found=1; #right before found should be 0 and $buffer void
  }

# process msgstr
  if ($line =~/^msgstr / || $line =~/^msgstr\[0\]/ ) {
      $buffer = $buffer . "\t";
      $line =~ s/^msgstr //;
      $line =~ s/^msgstr\[0\] //;
      $found=2; #
  }

  if ($found) {
    chop $line;
    $inversa = reverse $line;
    chop $inversa;
    $line = reverse $inversa;
    $buffer = $buffer . $line;
  }
  
}
