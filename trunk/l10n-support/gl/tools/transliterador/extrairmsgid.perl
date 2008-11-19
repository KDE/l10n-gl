#!/usr/bin/perl -w
#Este script serve para extrair os textos orixe dun ficheiro po/pot.
#Pon cada msgid nunha só liña. Adicionalmente, elimina os atallos de teclado (&) e entidades xml (&algo;) e tamén os et (&&).
#De xeito incompleto, retira as etiquetas html.
#Utilización: cat ficheiro.po | [rota ao script]/extrairmsgid.perl > ficheirosaida.txt
#Este script é distribuido sob os termos da licenza GPL v2 ou posterior.
#Este script é unha adaptación dun ficheiro de script que formaba parte do paquete port2gal.


$found=0;
$buffer="";
while ($line = <STDIN>) {
  chomp $line;

  if ( ($line =~ /msgstr/) || ($line=~ /msgctxt/) || ($line eq "") || ($line =~ /^\#/) )   {
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

  if ($line =~ /^msgid/) {
    $line =~ s/msgid //;
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
