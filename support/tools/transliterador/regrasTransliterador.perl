#!/usr/bin/perl -w

# Script baseado no trabalho de Alberto Garcia: http://por2gal.elpiso.org/
# Modificações feitas por Pablo Gamallo
# Para usar este script desde um shell, deves respeitar a seguinte sintaxe:
# cat  input-file  | port2gal.perl  >  output-file


use strict;
use locale;
use POSIX;

setlocale(LC_CTYPE,"pt_PT");

#print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
#print " TRANSLITERAÇÃO AUTOMÁTICA AO GALEGO DO ILG-RAG (excusas pelos erros)  \n";
#print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
#print "\n";
#print "\n";

my $vogal =  "AEIOUaeiou";
my $consAll = "bBdDtTpPkKvVfFcCçÇzZkKlLrRnNmMpPjJxXsShHqQgGñÑ";

my $vogalacentuada =  "\[áàéíóúÁÀÉÍÓÚâêîôûüãÃõÕ\]";
my $symbol = "\[\?\!\¿\¡\%\&\/\(\)\+\*\"\=\.\,\;\:\]";
my $WChar = "(\[a-zA-ZáàéíóúÁÀÉÍÓÚçÇâêîôûüãÃõÕ\])";
my $NaoChar = "(\[ \?\!\¿\¡\%\&\/\(\)\+\*\"\'\=\.\,\;\:\])";
my $cons =  "(\[bBdDtTpPkKvVfFcCçÇzZkKlLrRnNmMpPjJxXsShHñÑ\])"; ##faltam q e g
my $crecente =  "(ia|ie|io|ue|ua|uo|gua|guo)";
my $decrecente = "(iu|eu|ei|oi|ou|ai|au)";
my $w = "a-zA-ZáàéíóúÁÀÉÍÓÚçÇâêîôûüãÃõÕäÄëËïÏöÖüÜ";

my $pronComposto = "|no-lo|no-los|no-la|no-las|vo-lo|vo-los|vo-la|vo-las|se-me|se-te|se-che|se-lle|se-lles|se-nos|se-vos|";
my $pron = "|me|te|mos|mas|mo|ma|tos|tas|to|ta|che|cho|cha|chas|chos|lo|los|o|os|la|las|a|as|lle|lles|llo|lla|llos|llas|llelo|llela|se|no|vo|nos|vos|nolo|nolos|nola|nolas|volo|volos|vola|volas|seme|sete|seche|selle|selles|senos|sevos";

#my $sufixV "((?:-m|-lh|-t)?)(e?);


 my @l = qw(
([sS])im i
([aA])li lí
([aA])i í
([bB]isa|[aA])vô(s?) bó
([bB]isa|[aA])vó(s?) boa
Adiciona(r|[aáãeéeíoóuú])- Engadi
adiciona(r|[aáãeéeíoóuú])- engadi
Adicion(a|[ms]) Engade
adiciona(a|[ms]) engade
apresent- present
Apresent- Present
apresent- present
([aA])rrast([aáãeéeíoóuú])- rrastr 
([cC])élula(s?) ela
([aA])ssim sí
([oO])bjet- bject
((?:[rR]e|[dD]es)?)([aA])to(s?) cto
((?:[rR]e|[dD]es)?)([aA])ç(ão|ões) cç
((?:[rR]e|[dD]es)?)([aA])cion- ccion
((?:[rR]e|[dD]es)?)([aA])tiv- ctiv
((?:[rR]e|[dD]es)?)([aA])tua(l|i|idade)(s?) ctua
((?:[rR]e|[dD])?)([eE])strutur- structur
((?:[aA]uto|[rR]e|[dD]es)?)([cC])arreg- arg
ecrã(s?) pantalla
Ecrã(s?) Pantalla
([fF])undo(s?) ondo
([hH])omem ome
([oO])ntem nte
já xa
Já Xa
cena(s?) escena
Cena(s?) Escena
([cC])oluna(s?) olumna
([dD])ê ea
([dD])ois ous
([dD])ívida(s?) ébeda
([dD])isponív- ispoñíb 
([eE])steja stea
([fF])aculdade(s?) acultade
([fF])ormatação- ormato
([fF])ormatações- ormatos
([hH])á ai
([tT])u i
((?:d|n|d?aqu)?)ele el
([vV])ocê(s?) ostede
([pP])el([oa]s?) ol
((?:sobre)?)tudo(s?) todo
((?:[cC]apit|[eE]st|[iI]rm|[aA]lem|[cC]rist)?)ão(s?) án
((?:[cC]ora|[dD]oa|[hH]iperliga|[lL]iga)?)ção zón
((?:[cC]ora|[dD]oa|[hH]iperliga|[lL]iga)?)ções zóns
((?:[cC]apit|[iI]rm|[aA]lem|[cC]rist)?)ã(s?) á
([Ll])has hela
([Ll])hos helo
([nN])em in
([cC])onteúdo(s?) ontido
([cC])ontrole(s?) ontrol
([dD])ado(s?) ato
([dD])ireit- ereit
([gG])uard- ard
([gG])rau(s?)- rao
([pP])ont(o?|os?|u?)- unt
pasta cartafol
pastas cartafoles
Pasta Cartafol
Pasta Cartafoles
([pP])aine- ane
mas pero
mas pero
Mas Pero
sob baixo
Sob Baixo
([dD])epois espois
([mM])ais áis
([mM])eio édio
([mM])ui oi
([mM])uit([oa]s?) oit
([tT])ambém amén
([aA])ssim s
([eEoO])xig([ei)- six
enquanto mentres
Enquanto Mentres
([eE])screver- scribir
([eE])screv- scrib
([pP])essoa([ls]|is?) ersoa
([sS])ou((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) on
([fF])ui((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) un
((?:[eE]s|[cC]on|[dD]e|[mM]an|[oO]b)?)[tT]eve((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) tivo
([fF])aç((?:o|a|as|amos|am))((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) ag
([fF])az((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ai
([fF])azem((?:-m|-lh|-t|-ch|-v|-n|-s|o|-a)?([eoa]?(s?))) an
([fF])azes((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) as
([fF])iz((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ixen
([fF])ez((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ixo
fech- pech 
Fech- Pech 
([pP])ôs((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uxo
([pP])ôde((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uido
((?:[cCdDhHmMpPtTvV])?)ão(s?) an
([nsNS])ão on
((?:[eE]s|[cC]on|[dD]e|[mM]an|[oO]b)?)[tT]êm((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) teñen
([vV])êm((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) eñen
?([vV]|[lL]|[cC]r)êem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) en
?([vV]|[lL]|[cC]r)ê((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) e
([vV])ais((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) as
?(ór)([bpdtkvgfcçzkjxslmnr])ão(s?) ao
([pP])osso((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) odo
([pP])ossa(s|mo(s?)|m)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) oida
([pP])eç(amo(s?)|am)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) id
([pP])eço((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ido
([vV])eio((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) eu
([pP])õe((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) on
([pP])ões((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) os
([pP])õem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) oñen
([dD])iz((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) i
([dD])izes((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) is
([dD])izem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) in
([dD])ize- ici
([eE])scut- scoit
([pP])ergunt- regunt
([dD])iss(e|este|emo(s?)|eram|esse(m|s?)|éssemo(s?)|era(m|s?)|éramo(s?))((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ix
([dD])ixe((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ixo
([fF])iz(este|emo(s?)|eram|esse(m|s?)|éssemo(s?)|era(m|s?)|éramo(s?))((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ix
([qQ])uis(este|emo(s?)|eram|esse(m|s?)|éssemo(s?)|era(m|s?)|éramo(s?))((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uix
([qQ])uis((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uixo
([mM])uit- oit
([cC])oisa(s?) ousa
([mM])au(s?) alo
([mM])á(s?) ala
relatório(s?) informe
Relatório(s?) Informe 
([rR])epto(s?) eto 
([tT])abela(s?) áboa 
([sS])om(a|ar|a-) um
([vV])oltar(a|á|ã|e|s|mos|ais|ei|o?) olver
([uU])tente(s?) suário
qua- ca
Qua- Ca
quo- co
Quo- Co
gest- xesti
Gest- Xesti
questi?- cuesti
Questi?- Cuesti
([fF])requ(ên|en)- recu
([gG])ov- ob
(ha|de)v- b
([AaEeOoUu])i([lrnm])([bpdtkvgfcçzkjxs])- í
?([bBdDtTpPkKvVfFcCçÇzZkKlLrRnNmMjJxXsShH])([aeou])i([lrnm])([bpdtkvgfcçzkjxs])- í
?([AaEeOoIi])u([lrnm])([bpdtkvgfcçzkjxs])- ú
?([bBdDtTpPkKvVfFcCçÇzZkKlLrRnNmMjJxXsShH])uí([bpdtkvgfcçzkjxs])- ui
-([çs])ão ión
-([çs])ões ións
-õe(s?) ón
-ães áns
-rrão rrón
-rão rán
--ão -án
-ão ón
-ã(s?) án
-eio(s?) eo
-eia(s?) ea
-imento(s?) emento
-ói([oa])(s?) oi
-([aei])ram ron
-(g)em e
-(g)ens es
-([áéíóú])vel bel
-([áéíóú])veis beis
-ava((?:s|mos|m)?) aba
-ava((?:s|mos|m)?-)- aba
-ávamos ábamos
-ámos amos
-éu eu
-m n
-nh- ñ
-ss- s
-vr- br
-([aei])ste ches
-(g)ens es
?lh- ll
?[çz]([ei])? c
?g([eiéíêî])? x
?[ÇZ]([ei])? C
?G([eiéíêî])? X
([nN])eñun ingún
([nN])eñuma ingunha
((?:[nN]|[dD]|[cC]|[dD]?alg)?)[uU]mh?a(s?) unha
([Ss])ão-([\w]+)- om-
([Ss])ou-([\w]*)- om-
([dDvV])ão-([\w]+)- am-
-rão-([\w]+)- rám-
-m-n(o|a|as|os) n-
-m-([\w]*)- n-
-i-l(o|a|as|os) í-l
pós-- post
);



my $line;
while ($line = <>) {

    chop $line;
    $line = " $line ";
    $line =~ s/ /  /g;
    $line =~ s/\. / \. /g;
    $line =~ s/\.$/ \. /g;
    $line =~ s/\, / \, /g;
    $line =~ s/\; / \; /g;
    $line =~ s/\?/ \? /g;
    $line =~ s/\!/ \! /g;
    $line =~ s/\[/\[ /g;
    $line =~ s/\]/ \] /g;
    $line =~ s/\(/\( /g;
    $line =~ s/\)/ \) /g;
    $line =~ s/\"/\" /g;
    
    #print STDERR "$line\n";
 


    #trocas da lista de pares irregulares $l:
    my $i;
    for ($i=0;$i<$#l;$i+=2) {
      my ($a,$b) = ($l[$i],$l[$i+1]);
      #print STDERR "$a $b\n";
     #$a =~ s/^([^\?-])/(\\W)$1/;
     #$a =~ s/([^\?-])$/$1(\\W)/;
      $a =~ s/^([^\?-])/$NaoChar$1/;
      $a =~ s/([^\?-])$/$1$NaoChar/;

      #$a =~ s/(^-|-$)/(\\w)/g;
      $a =~ s/(^-|-$)/$WChar/gi;
      $a =~ s/(^\?|\?$)/(.)/gi;
      $a =~ s/\)\(//gi;
     # print STDERR "$a $b\n";
     # $line =~ s/$a/$1$b$2/gi;
      $line =~ s/$a/$1$b$2/gi;

      #print STDERR "$line\n";
    }

    #trocas de mais duma palavra (contracções prep+art e outros...)
    $line =~ s/ con  a(s?) /coa$1 /gi;
    $line =~ s/ con  o(s?) /co$1 /gi;
    $line =~ s/ con  unha(s?) /cunha$1 /gi;
    $line =~ s/ con  un(s?) /cun$1 /gi;
    $line =~ s/ de  unha(s?) /dunha$1 /gi;
    $line =~ s/ de  un(s?) /dun$1 /gi;
    $line =~ s/ en  unha(s?) /nunha$1 /gi;
    $line =~ s/ en  un(s?) /nun$1 /gi;
    #$line =~ s/(v(o)u|v(as)|v(a)i|v(amos)|v(ades)|v(an))  embora/march$2$3$4$5$6$7/gi;


    #trocas de grafias especiais
    $line =~ y/çàãõâêôûjÇÀÃÕÂÊÔÛJ/záaoáéóúxZÁAOÁÉÓÚX/;
         #print STDERR "temp: $line\n";
  
  #troca os futuros com pronomes proclíticos: dar-lhes-emos por daremoslhes.
    
     $line =~  s/á-(l[oa]s?)-([$w]+)/a-$1-$2/i ;
     $line =~  s/é-(l[oa]s?)-([$w]+)/e-$1-$2/i ;
     $line =~  s/í-(l[oa]s?)-([$w]+)/i-$1-$2/i ;     
     $line =~  s/ó-(l[oa]s?)-([$w]+)/o-$1-$2/i ;
     $line =~  s/ú-(l[oa]s?)-([$w]+)/u-$1-$2/i ;
     #print STDERR "inter: temp: $line\n";

     $line =~  s/-l([oa]s?)-eis/rédel-$1/gi;  
     $line =~  s/-l([oa]s?)-íeis/riédel-$1/gi;  
     $line =~  s/-(l[oa]s?)-(ás|emos|ias|íamos)/r$2-$1/gi;
     $line =~  s/-l([oa]s?)-(ei|án|á|ian?)/r$2-$1/gi;   
     
     $line =~  s/s-l([oa]s?)/-l$1/gi;
      
     $line =~  s/-([$w]+)-eis/rédel-$1/gi;  
     $line =~  s/-([$w]+)-íeis/riédel-$1/gi;  
     $line =~  s/-([$w]+)-(ás|emos|ias|íamos)/$2-$1/gi;
     $line =~  s/-([$w]+)-(ei|án|á|emos|ian?)/$2-$1/gi;

	 #print STDERR "temp: $line\n";
    #tira os guioes: 
    # $line =~ s/(?<=\w)á-(?=\w{0,4}$NaoChar)/a/gi;
   # $line =~ s/(?<=\w)-(?=\w{0,4}$NaoChar)//gi;

    $line =~ s/  / /g;
    $line =~ s/^ //g;
    $line =~ s/ $//g;
    #print STDERR "$line\n" ;

    #regras de acentuação:
    my @listPals;
    my $p;
    (@listPals) = split (" ", $line);
    $line="";
    foreach $p (@listPals) {

       ##comia, tio, ...
       if (($p !~ /$vogalacentuada/) && 
           ($p =~ /$cons(i[aoe])([ns]?)($symbol?)$/i) ) {

           $p =~ s/i([aoe])([ns]?)($symbol?)$/í$1$2$3/i

      }
       ##sua, possuo, crua, ...
       elsif (($p !~ /$vogalacentuada/) && 
           ($p =~ /$cons(u[aoe])([ns]?)($symbol?)$/i) ) {

           $p =~ s/u([aoe])([ns]?)($symbol?)$/ú$1$2$3/i

      }

       ## aqui/latim/tabu, ...
       elsif (($p !~ /$vogalacentuada/) && 
           (length($p) >= 4) && 
           ($p !~ /(tui|$decrecente)(s?)($symbol?)$/i) ) {

           $p =~ s/i([nmsx]?)($symbol?)$/í$1$2/i;
           $p =~ s/u([nmsx]?)($symbol?)$/ú$1$2/i;
      }
       ##táxi/júri/bônus
       elsif (($p =~ /$vogalacentuada/) && 
           (length($p) >= 4) && 
           ($p =~ /$cons(i|u)(s?)($symbol?)$/i) ) {
          

           $p =~ y/áéíóú/aeiou/;
       }


        ##/tênue/régua (ditongo crecente...)
       elsif (($p =~ /$vogalacentuada/) && 
              ($p =~ /$cons($crecente)(s?)($symbol?)$/i) ) {

            $p =~ y/áéíóú/aeiou/;

      }

        ##/espanhóis/caracóis
      elsif ($p =~ /óis($symbol?)$/i) {
          
           $p =~ s/óis($symbol?)$/ois$1/i;
           

      } 

        ##/sair/constituir
      if (($p !~ /$vogalacentuada/) 
           && ($p =~ /$cons(ui|ai|ei)([rln])($symbol?)$/i)  ) {
          
           $p =~ s/i([rln])($symbol?)$/í$1$2/i;
           $p =~ s/u([rln])($symbol?)$/ú$1$2/i;

      }

     


       my $des="";
       my $raiz="";
       my $v="";
       my $first="";
       my $last="";

 ##pronomes compostos: no-las, se-me
       if (($p =~ /[$w]+\-[$w]+\-[$w]+/i) && ($p !~ /[0-9]+\-[0-9]+\-[0-9]+/i) ) {
	   ($raiz, $des) = ($p =~ /([$w]+)-([^ ]+)/i);
           #print STDERR "$raiz - $des\n";
           if ( ($raiz ne "") && ($des ne "")) {	    

               if (pertence ($des, $pronComposto)) {
                 $des =~ s/-//i;
                 $p = $raiz . "-" . $des;
	       } 
            }  
       }
       elsif (pertence ($p, $pronComposto )) {
             $p  =~ s/-//;
       }


        ## acentos de verbos com pronomes: chamo-me > chámome
       if (($p =~ /[$w]+\-[$w]+$/i) && ($p !~ /[0-9]+\-[0-9]+/i) && ($p !~ /[$w]+\-[$w]+\-[$w]+/i)) {
	   ($raiz, $des) = ($p =~ /([$w]+)-([$w]+)/i);
           #print STDERR "2: $raiz - $des\n";
           if ( ($raiz ne "") && ($des ne "")) {
              ($des =~ s/llos/llelo/i); 
              ($des =~ s/llas/llela/i); 
             if (pertence ($des ,$pron)) {
              

              if ( ($raiz !~ /$vogalacentuada/) && ($raiz =~ /[$w]*[$vogal][$consAll]+[$vogal]([ns]?)$/i) ) {     
                   #print STDERR "OKKK\n";   
                   ($first, $v, $last) = ($raiz =~ /([$w]*)([$vogal])([$consAll]+[$vogal]([ns]?))$/i);

                   if ($v ne "") {
		       $v = PorAcento($v);
                       $p = $first . $v .  $last . $des;
                      # print STDERR "regra1: $v\n";
                    }
               }
              elsif ( ($raiz !~ /$vogalacentuada/) && ($raiz =~ /[qg]u[$vogal]$/i) ) {        
                   ($first, $v, $last) = ($raiz =~ /([^ ]*)([$vogal])(([$consAll]?)[qg]u[$vogal])$/i);

                   if ($v ne "") {
		       $v = PorAcento($v);
                       $p = $first . $v .  $last . $des;
                       #print STDERR "regra1b: $v\n";
                    }
               }

              elsif ( ($raiz !~ /$vogalacentuada/) && ($raiz =~ /[$vogal][$vogal]$/i) &&
                      ($raiz !~ /$decrecente$/)  ) {        
                     ($first, $v, $last) = ($raiz =~ /([^ ]*)([$vogal])([$vogal])$/i);

                   if ($v ne "") {
		       $v = PorAcento($v);
                       $p = $first . $v .  $last . $des;
                       #print STDERR "regra1b: $v\n";
                    }
               }

	      elsif  ( ($raiz =~ /$vogalacentuada([ns]?)$/) && ($raiz !~ /^é|^dá([ns]?)$/i) ) {
                   ($first, $v, $last) = ($raiz =~ /([$w]*)($vogalacentuada)([ns]?)$/i);
                   if ($v ne "")  {
		       $v = TirarAcento($v);
                       $p = $first . $v . $last . $des;
                       #print STDERR "$first  $v  $last\n";
                    }
	     }
             elsif ($raiz =~ /$vogalacentuada/) {
                      $p = $raiz . $des;
                      #print STDERR "regra3\n";
	     
             }
             ##raiz acaba em ditongo crecente : por acento na primeira vogal
	     elsif ( ($raiz =~ /$crecente[ns]?$/) && ($raiz !~ /que$|gue$/i)) {
                ($raiz =~ s/([$w]+)i([aeo][ns]?$)/$1í$2/i);
                ($raiz =~ s/([$w]+)u([aeo][ns]?$)/$1ú$2/i);
                 $p = $raiz . $des;
                 #print STDERR "regra IA\n";
	    }
            elsif ( ($raiz =~ /$decrecente$/) &&  ($des =~ /^[oa]/i) ){
                      $p = $raiz . "n" . $des;
                      #print STDERR "regra3\n";
	     
             }
            
            else {
		  $p = $raiz . $des;
		 # print STDERR "others..\n";
	      }
           }
	}
       }




     ## Metacorrecções:

      $p =~ s/^([cC])ontrache/$1ontraste/i;
      $p =~ s/^([nN])eche/$1este/i;
      $p =~ s/^([eE])xiche/$1xiste/i;
      $p =~ s/^([lL])inúx/$1inux/i;
      $p =~ s/^([xX])aba/Java/i;
      $p =~ s/^([mM])aíl/$1ail/i;
      $p =~ s/^([cC])orpús/$1orpus/i;
      $p =~ s/^([pP])lug-ín/$1lugin/i;
      $p =~ s/^([fF])unctíon/$1unction/i;
      $p =~ s/^([aA])rraches/$1rrastre/i;
      ##reíntroduzir
      $p =~ s/^([Rr])eín/$1ein/i;

      #so para textos de info. 
      $p =~ s/^clique/prema/;
      $p =~ s/^Clique/Prema/;


      $line .= $p . " ";
    }

my $SpetialChar = "\?\!\¿\¡\%\&\/\(\)\\\+\*\'\=\.\,\;\: ";
    
    $line =~ s/ \. /\. /g;
    $line =~ s/ \; /\; /g;
    $line =~ s/ \, /\, /g;
    $line =~ s/ \? /\? /g;
    $line =~ s/ \! /\! /g;
    $line =~ s/\[ /\[/g;
    $line =~ s/ \] /\] /g;
    $line =~ s/\( /\(/g;
    $line =~ s/ \) /\) /g;
           
    $line =~ s/\" ([$w$SpetialChar]*) \"/\"$1\"/g;
    $line =~ s/ ([\]\)])($SpetialChar)/$1$2/g;
    
    print "$line\n";
}


sub PorAcento {
    my $result;
    my $x;

    ($x) = $_[0];
    
    
    if ($x eq "a") {$result = "á"};
    if ($x eq "e") {$result = "é"};
    if ($x eq "i") {$result = "í"};
    if ($x eq "o") {$result = "ó"};
    if ($x eq "u") {$result = "ú"};
    if ($x eq "A") {$result = "Á"};
    if ($x eq "E") {$result = "É"};
    if ($x eq "I") {$result = "Í"};
    if ($x eq "O") {$result = "Ó"};
    if ($x eq "U") {$result = "Ú"};
    return $result;

}

sub TirarAcento {
    my $result;
    my $x;

    ($x) = $_[0];
    
    
    if ($x eq "á") {$result = "a"};
    if ($x eq "é") {$result = "e"};
    if ($x eq "í") {$result = "i"};
    if ($x eq "ó") {$result = "o"};
    if ($x eq "ú") {$result = "u"};
    if ($x eq "Á") {$result = "A"};
    if ($x eq "É") {$result = "E"};
    if ($x eq "Í") {$result = "I"};
    if ($x eq "Ó") {$result = "O"};
    if ($x eq "Ú") {$result = "U"};
    return $result;

}


sub pertence {
    my $subcadeia;
    my $cadeia;
    my $temp;

    ($subcadeia) = $_[0];
    ($cadeia) = $_[1];

    $temp = "|" . $subcadeia . "|";
    if (index ($cadeia, $temp) ==-1) {
        return 0;
    }
    else {
        return 1;
    }
}








