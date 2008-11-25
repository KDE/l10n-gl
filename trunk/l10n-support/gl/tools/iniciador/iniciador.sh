#! /usr/bin/env bash


if [ -z "$BASE_REPO" ] ; then
   echo "BASE_REPO not set, please run trasno_firsttime.sh first" >&2
   exit 1
fi

if [ $# -ne 3 ]; then
   echo "Usage: iniciar.sh language trunk|stable gui|docs" >&2
   exit 1
fi

idiom=$1

if [ "$2" = "trunk" -o "$2" = "TRUNK" ]; then
    branch="trunk/l10n-kde4"
elif [ "$2" = "stable" -o "$2" = "STABLE" ]; then
    branch="branches/stable/l10n-kde4"
else
    echo "second argument must be one in \"trunk\" or \"stable\"" >&2
    exit 1
fi


if [ $3 = "gui" -o $3 = "GUI" ]; then
    subdir="messages"
elif [ $3 = "docs" -o $3 = "DOCS" ]; then
    subdir="docmessages"
else
    echo "third argument must be one in \"gui\" or \"docs\"" >&2
    exit 1
fi

newones_po=""
newones_pot=""

for file in `find "${BASE_REPO}/${branch}/templates/${subdir}/" -name "*.pot"`; do
    directory=`dirname $file`
    module=`basename $directory`
    candidate=${BASE_REPO}/${branch}/${idiom}/${subdir}/${module}/`basename "$file" .pot`".po"
    if [ ! -f $candidate ]; then
        msginit -i $file -o $candidate --no-translator
        echo $candidate >> ${BASE_REPO}/_tmp.$$.1
        echo $file >> ${BASE_REPO}/_tmp.$$.2
    fi
done

kioexec "./auxiliar_iniciador.sh ${BASE_REPO}/_tmp.$$.1 ${BASE_REPO}/_tmp.$$.2" http://i18n.kde.org/po_overview/${idiom}.messages
rm ${BASE_REPO}/_tmp.$$.1 ${BASE_REPO}/_tmp.$$.2