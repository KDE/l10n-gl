#! /usr/bin/env bash
# TRanslation Not Yet Satisfied Built Employing A Chain of Hacks

function check_xml() 
{
    if test -f $trans_doc; then
        case $trans_doc in
            */api/index.docbook) ;;
            */index.docbook|*/man-*.docbook)
                if ! $MEINPROC --check --stdout $trans_doc > /dev/null; then
                    $MEINPROC --check --stdout $trans_doc
                    if test "$delete" -eq 1; then
                        echo "RESTORING $trans_doc"
                        echo "RESTORING $trans_doc">>update_xml.log
                        rm -f $trans_doc
                        svn revert $trans_doc  
                    else
                        echo "Failed on $trans_doc. Exiting."
                        exit 1
                    fi
                fi
                ;;
            *) ;;
        esac
    fi
}

function complete_po_conversion()
{
    docbookFile=$1
    poFile=$2
    moduleDocsDir=$3
    echo po2xml $docbookFile $poFile
    if ! po2xml $docbookFile $poFile > ${prefix}/temp.xml; then
        echo "ERROR: po2xml $docbookFile $poFile failed! Exiting!"
        exit 1
    fi
    language=`cat $moduleDocsDir/../language `
    if test -n "$language"; then 
        sed -e "s,<!ENTITY % English,<!ENTITY % $language," ${prefix}/temp.xml > ${prefix}/temp.xml.new
        mv ${prefix}/temp.xml.new ${prefix}/temp.xml
    fi
}

function uncomplete_po_conversion()
{
exit;
}

LANG=C
LC_ALL=C
LC_MESSAGES=C

# Check for some version of meinproc
MEINPROC=""
for i in "meinproc4" "meinproc"; do
   j=`which ${i} 2>/dev/null`
   test -x "${j}" && MEINPROC="${j}" && break
done
test -z "${MEINPROC}" && echo "No suitable version of meinproc was found. Exiting..." && exit 1

# Check for some version of transxx
TRANSXX=`which transxx 2>/dev/null`
test -z "${TRANSXX}" -o ! -x"${TRANSXX}" && echo "No suitable version of transxx was found. Exiting..." && exit 1

if test $# -eq 0 || test "$1" = "--help" ; then
  echo "trannybeach.sh [--nodelete] <branch> <lang_lang> [selection [single_catalog]]"
  exit
fi

delete=1
if test "$1" = "--nodelete"; then
  delete=0
  shift
fi


if test "$1" != "trunk" -a "$1" != "branches"; then
  echo "trannybeach.sh [--nodelete] <branch> <lang_lang> [selection [single_catalog]]"
  echo "<branch> must be either \"trunk\" or \"branches\""
  exit
fi
branch=$1
lang=$2

selection=$3
if test -z "$selection"; then
   selection=*
fi

singlecat=$4

prefix=${BASE_REPO}/${branch}/l10n-kde4
modules=`ls -1 ${prefix}/documentation`

for m in $modules; do
   test -d ${prefix}/documentation/$m || continue

   files=`find -H ${prefix}/documentation/$m -name "*.docbook"`

   if test -n "$files"; then
    for i in $files; do
        case $i in   #do nothing if the filename is not in the selection
            *_original.docbook)
            continue
            ;;
            *$selection*)
            ;;
            *)
            continue;;
        esac

    #    j=`echo $i | sed -e "s#documentation/$m/##" | sed -e 's#.docbook$##' | sed -e 's#/index$##' | sed -e "s#/#_#g"`
        j=`echo $i | sed -e "s#${prefix}/documentation/$m/##" | sed -e 's#.docbook$##' | sed -e 's#/index$##' | sed -e "s#/#_#g"`
        translations=`ls -1 ${prefix}/${lang}/docmessages/${m}/${j}.po 2>/dev/null`
        for t in $translations; do
            # If a single catalog selected, skip unless this is the one.
            if test -n "$singlecat"; then
                test `basename $t | sed "s#/$singlecat.po##"` = $t && continue
            fi
            bd=`dirname $t`
        #       p=`echo $i | sed -e "s#documentation/$m/##"`
            p=`echo $i | sed -e "s#${prefix}/documentation/$m/##"`
            trans_doc="$bd/../../docs/$m/$p"
            dir=`dirname $trans_doc`
            mbase=`dirname $dir`
#marce
            result=`msgfmt -o /dev/null --statistics $t 2>&1`
                ret=$?
                if test $delete -eq 0 && test "$ret" -ne 0; then
                    echo "ERROR: msgfmt $t failed. Exiting."
                    exit 1
                fi
                if test "$ret" -ne 0 || echo $result | grep -q untranslated || echo $result | grep -q fuzzy; then
                    echo "${m}/${j}.po: $result"
#ei-lo, se hai non traducidas, ou dubidosas non segue: redirixir ao novo
                    continue
                fi
# #esta é a maneira estandar de procesar
#             echo po2xml $i $t
#             if ! po2xml $i $t > temp.xml; then
#                         echo "ERROR: po2xml $i $t failed! Exiting!"
#                         exit 1
#             fi
#             language=`cat $bd/../language `
#             if test -n "$language"; then 
#                 sed -e "s,<!ENTITY % English,<!ENTITY % $language," temp.xml > temp.xml.new
#                 mv temp.xml.new temp.xml
#             fi
            complete_po_conversion $i $t $bd
exit
            lang=$lang
        
            # call external postfilter if it exists
            postfilter="$bd/../post-po2xml"
            if test -x $postfilter; then
                if $postfilter <temp.xml >temp.xml.new; then
                    mv temp.xml.new temp.xml
                else
                    echo "ERROR: $postfilter failed! Exiting!"
                    rm -f temp.xml.new
                    exit 1
                fi
            fi
        
            # if missing, add base module dir to svn (<lang>/docs/<base module>)
            if test ! -d $mbase/.svn; then
                mkdir -p $mbase
                svn add -N $mbase
            fi
            
            if test ! -d $dir/.svn; then
                mkdir -p $dir
                rm -f $trans_doc
                mv temp.xml $trans_doc
                echo Makefile > ignore.$$
                echo CMake* >> ignore.$$
                # For those who build in the same dir:
                echo *.cmake >> ignore.$$
                echo DartTextfile.txt >> ignore.$$
                svn add $dir
                svn ps svn:ignore -F ignore.$$ $dir
                rm ignore.$$
            else
                if ! cmp -s temp.xml $trans_doc; then
                    :
                    rm -f $trans_doc
                    mv temp.xml $trans_doc
                    if test "`svn status $trans_doc | cut -b-6`" = '?     ';  then
                    svn add $trans_doc 
                    fi
                else
                    rm temp.xml
                fi
            fi
            check_xml
        done
    done
   fi
done
