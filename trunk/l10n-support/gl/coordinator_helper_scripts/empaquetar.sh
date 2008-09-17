#! /usr/bin/env bash
#o proposito deste script é criar un paquete tar.bz contendo os ficheiros
#modificados polo tradutor, na mesma estrutura en árbore que este os ten, de
#xeito que podan ser facilmente desempaquetados polo coordinador no lugar
#correcto, e se este ten modificacións locais, noutro lugar para ver o que facer
#Usage: empaquetar.sh <lang> <tradutor> [BASE_REPO]

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