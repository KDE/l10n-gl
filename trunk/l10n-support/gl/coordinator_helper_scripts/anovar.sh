#! /usr/bin/env bash
#Este script serve para actualizar os repositorios, resolver os conflitos entre
#versións, procesar os orfos e algunha cousa máis.
#LER O FICHEIRO AXUDA.TXT ANTES DE UTILIZAR!!!!!

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
tar cvf $BASE_REPO/db_backup`date +%F`.tar $HOME/.kde/share/apps/kbabeldict/dbsearchengine/

for lugar in {trunk/l10n-kde4,branches/stable/l10n-kde4,trunk/l10n-support}/{scripts,templates,$code,documentation,pology}; do #anovamos a galla
    if [ -d $BASE_REPO/$lugar/.svn ]; then
        echo "$lugar"
        svn update --quiet $BASE_REPO/$lugar
    fi
done

for galla in trunk branches/stable; do #arranxamos os conflitos (mediante trad_colisions.sh)
    if [ -d $BASE_REPO/$galla/l10n-kde4/$code ] ; then
        trad_colisions.sh `echo $galla | cut -d"/" -f1` $code
    else
        echo "Language $code is not present under branch $galla"
    fi

    if [ -x $BASE_REPO/$galla/l10n-kde4/scripts/process_orphans.sh ]; then #procésanse os orfos e vese cais po non teñen pot
        cd $BASE_REPO/$galla/l10n-kde4/
        $BASE_REPO/$galla/l10n-kde4/scripts/process_orphans.sh &> /dev/null
        if [ -x $BASE_REPO/$galla/l10n-kde4/scripts/find_po_without_pot.sh ]; then
            $BASE_REPO/$galla/l10n-kde4/scripts/find_po_without_pot.sh $code
        fi
    fi
done