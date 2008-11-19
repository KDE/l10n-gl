#! /usr/bin/env bash

if [ $# -lt 1 -o $# -gt 2 ]; then
   echo "Usage: transliterar.sh ficheiro_po" >&2
   exit 1
fi

ficheiro=$1

msgconv $ficheiro -t iso-8859-15 -o $ficheiro.$$

#Utilización: cat ficheiro.po | [rota ao script]/extrairmsgid.perl > ficheirosaida.txt
cat $ficheiro.$$ | ./extrairmsgid.perl  > __msgid.$$.tmp
cat $ficheiro.$$ | ./extrairmsgstr.perl | ./regrasTransliterador.perl | ./regrasVerbos.perl ./verbos23.txt > __msgstr.$$.tmp

LINES=`wc -l __msgstr.$$.tmp | cut -f1 -d" "`
LINE=0
while [ $LINE -le $LINES ]
do
  LINE=`expr $LINE + 1`
  if [ $LINE -gt 1 ]; then
   echo "# transliterado"
   echo "msgctxt \"${LINE}\""
  else
   echo "#Ficheiro transliterado"
   echo "msgid \"\""
   echo "msgstr \"\""
   echo "\"Mime-Version: 1.0\n\""
   echo "\"Content-Type: text/plain; charset=ISO-8859-15\n\""
   echo "\"Content-Transfer-Encoding: 8bit\n\""
   echo
   continue
  fi
  echo "msgid \"`head -"$LINE" __msgid.$$.tmp | tail -1`\""
  echo "msgstr \"`head -"$LINE" __msgstr.$$.tmp | tail -1`\""
  echo
done
# ./hcat.sh __msgid.$$.tmp __msgstr.$$.tmp > temporal
#linhas=`wc -l __temporal.$$.tmp | cut -f1 -d" "`

#tail -n`expr $linhas - 2`  __temporal.$$.tmp > temporal

rm  $ficheiro.$$ __msgid.$$.tmp __msgstr.$$.tmp
