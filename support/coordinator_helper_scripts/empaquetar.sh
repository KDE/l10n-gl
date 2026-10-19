#! /usr/bin/env bash
#o proposito deste script é criar un paquete tar.bz contendo os ficheiros
#modificados polo tradutor, na mesma estrutura en árbore que este os ten, de
#xeito que podan ser facilmente desempaquetados polo coordinador no lugar
#correcto, e se este ten modificacións locais, noutro lugar para ver o que facer
#Usage: empaquetar.sh <lang> <tradutor> [BASE_REPO]
# Copyright (c) 2008, Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of Marcelino Villarino Aguiar nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
if [ $# -lt 2 ] ; then
   echo "Usage: empaquetar.sh lang_code translator [BASE_REPO]"
   exit 2
else
   $lang=$1
   $tradutor=$2
fi

if [ $# -eq 3 ]; then
   if [ -d $3 ]; then
      BASE_REPO=$3
   else
      echo "Given \$BASE_REPO is not a directory"
      exit 2
   fi
fi

if [ -z $BASE_REPO ] ; then
   echo "\$BASE_REPO not set"
   exit 2
fi

entrega=entrega_$tradutor_`date+%F`.tar

for galla in trunk/l10n-kde4 branches/stable/l10n-kde4;do
   if [ -d $BASE_REPO/$galla/$lang ] ; then
      #PROCURA OS MODIFICADOS/ENGADIDOS/INCOGNITA, E ENGÁDEOS AO PAQUETE
      $ficheiros=`svn status $BASE_REPO/trunk/l10n-kde4/gl | grep [MC?] | cut \
-d" " -f7 | sed "s:^$BASE_REPO::"`
      tar vfr  $entrega $ficheiros
   else
      echo "Language $lang is not present under $galla"
   fi
done
bzip2 $entrega && rm $entrega