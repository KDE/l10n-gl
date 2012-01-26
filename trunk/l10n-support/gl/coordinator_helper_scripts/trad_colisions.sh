#! /usr/bin/env bash
# Automatiza a resolución de conflitos entre a copia local e a referente,
# tomando sempre as modificacións locais (suponse que só hai unha persoa a
# traducir cada ficheiro. Execútase como parte de "anovar.sh"
# usage: trad_colisions.sh <version> <lang> [<base_repo>]
# where: <version> is one in stable or trunk (anything else 
#        and <lang> is the language code (the subdir name)
#        optionally, the base directory of the translation project can be
#        explicitly given. If not set, if will use a environment variable
#        called #$BASE_REPO
# Copyright (c) 2008, Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met: Redistributions
# of source code must retain the above copyright notice, this list of conditions
# and the following disclaimer. Redistributions in binary form must reproduce the
# above copyright notice, this list of conditions and the following disclaimer in
# the documentation and/or other materials provided with the distribution.
# Neither the name of Marcelino Villarino Aguiar nor the names of its
# contributors may be used to endorse or promote products derived from this
# software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.

case "$1" in
   stable)
      prefix=branches/stable/l10n-kde4
      ;;
   branches) #isto simplifica a vida en anovar.sh
      prefix=branches/stable/l10n-kde4
      ;;
   trunk)
      prefix=trunk/l10n-kde4
      ;;
   *)
      echo "Usage: trad_colisions.sh <version> <lang> [<base_repo>]"
      echo "branch is one in stable or trunk"
      exit 2
    ;;
esac

if [ $# -eq 3 ] && [ -e $3 ] ; then
   BASE_REPO=$3
fi
if [ -z $BASE_REPO ] ; then
   echo "\$BASE_REPO not set"
   exit 2
fi

if [ -d $BASE_REPO/$prefix/$2 ] ; then
   lang=$2
else
   echo "Language $2 is not present under branch $1"
   exit 2
fi


marca="mine"
cd $BASE_REPO

echo "...solving conflicts on $1 ($BASE_REPO/$prefix/$lang) ..."
for ficheiro in `svn status $BASE_REPO/$prefix/$lang/ | grep "^C " | cut -d" " -f8`
  do
    directorio=`dirname $ficheiro`
    nome=`basename $ficheiro ."$marca"`
    svn resolve --accept mine-full $directorio/$nome
    postpath=`echo $directorio | sed "s:$prefix/$lang::"` #cut --delimiter="/" --fields=2- -`
    echo "    postprocesando: ${directorio}/${nome} con ${BASE_REPO}/${prefix}/templates/${postpath}/${nome}t"
    $BASE_REPO/$prefix/scripts/merge.sh ${directorio}/${nome} ${BASE_REPO}/${prefix}/templates/${nome}t
  done
echo "...done $1"
