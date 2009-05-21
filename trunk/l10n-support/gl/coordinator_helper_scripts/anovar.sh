#! /usr/bin/env bash
#Este script serve para actualizar os repositorios, resolver os conflitos entre
#versións, procesar os orfos e algunha cousa máis.
#LER O FICHEIRO AXUDA.TXT ANTES DE UTILIZAR!!!!!

# Copyright (c) 2008, Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# Neither the name of Marcelino Villarino Aguiar nor the names of its
# contributors may be used to endorse or promote products derived from this
# software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
if [ -z "$BASE_REPO" ] ; then
   echo "BASE_REPO not set, please run trasno_firsttime.sh first" >&2
   exit 1
fi

if [ $# -lt 1 -o $# -gt 2 ]; then
   echo "Usage: anovar.sh lang_code [cache_ssh]" >&2
   exit 1
fi

code=$1
ssh_key=$2

if [ ! -f "${HOME}/.ssh/${ssh_key}" ]; then
    echo "There is no ${HOME}/.ssh/${ssh_key}, exiting"
    exit 1
elif [ "$ssh_key" ]; then
    ssh-add ${HOME}/.ssh/${ssh_key}
fi

# antes que nada, facemos unha copia de seguranza da bbdd de traduzón
#tar cvf $BASE_REPO/db_backup`date +%F`.tar $HOME/.kde/share/apps/kbabeldict/dbsearchengine/

for lugar in {trunk/l10n-kde4,branches/stable/l10n-kde4,trunk/l10n-support}/{scripts,templates,$code,documentation,pology}; do #anovamos a galla
    if [ -d $BASE_REPO/$lugar/.svn ]; then
        echo "$lugar"
        svn update --quiet $BASE_REPO/$lugar
    fi
done
echo "END OF REPOSITORIES UPDATES, going to second stage"

for galla in trunk branches/stable; do #arranxamos os conflitos (mediante trad_colisions.sh)
    if [ -d $BASE_REPO/$galla/l10n-kde4/$code ] ; then
        trad_colisions.sh `echo $galla | cut -d"/" -f1` $code
    else
        echo "Language $code is not present under branch $galla"
    fi

    if [ -x $BASE_REPO/$galla/l10n-kde4/scripts/process_orphans.sh ]; then #procésanse os orfos e vese cais po non teñen pot
        echo "...will now process orphans of $galla"
        cd $BASE_REPO/$galla/l10n-kde4/
        $BASE_REPO/$galla/l10n-kde4/scripts/process_orphans.sh &> /dev/null
        if [ -x $BASE_REPO/$galla/l10n-kde4/scripts/find_po_without_pot.sh ]; then
            echo "...checking for po files without associated po file on $galla"
            $BASE_REPO/$galla/l10n-kde4/scripts/find_po_without_pot.sh $code
        fi
    fi
done
