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

case "$1" in
   stable)
      prefix=branches/stable/l10n-kde4
      ;;
   branches) #hack para simplificar a vida en anovar.sh
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

echo "...solving conflicts on $1 ..."
for ficheiro in `find $prefix/$lang -name *."$marca"`
  do
    directorio=`dirname $ficheiro`
    nome=`basename $ficheiro ."$marca"`
    echo "PRESENTABA CONFLITOS: $nome"
    cp $ficheiro $directorio/$nome
    svn resolved $directorio/$nome
    postpath=`echo $directorio | sed "s:$prefix/$lang::"` #cut --delimiter="/" --fields=2- -`
    $BASE_REPO/$prefix/scripts/merge.sh $BASE_REPO/$directorio/$nome $BASE_REPO/$prefix/"templates"$postpath/$nome"t"
  done
echo "...done $1"