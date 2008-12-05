#! /usr/bin/env bash
# Copyright (c) 2008, Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of the Marcelino Villarino Aguiar nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
