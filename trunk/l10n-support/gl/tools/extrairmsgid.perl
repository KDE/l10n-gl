#!/usr/bin/perl -w
#Este script serve para extrair os textos orixe dun ficheiro po/pot.
#Pon cada msgid nunha só liña. Adicionalmente, elimina os atallos de teclado (&) e entidades xml (&algo;) e tamén os ampersand (&&).
#De xeito incompleto, retira as etiquetas html.
#Utilización: cat ficheiro.po | [rota ao script]/extrairmsgid.perl > ficheirosaida.txt
#Este script é distribuido sob os termos da licenza GPL v2 ou posterior.


$found=0;
while ($line = <STDIN>) {
  chomp $line;

  if ( ($line =~ /msgstr/) || ($line=~ /msgctxt/) || ($line eq "") || ($line =~ /^\#/) )   {
     if ($found==1) {print "\n"; $found=0; } else { $found=0; }
  }

  if ($line =~ /^msgid/) {
    $line =~ s/msgid //;
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
