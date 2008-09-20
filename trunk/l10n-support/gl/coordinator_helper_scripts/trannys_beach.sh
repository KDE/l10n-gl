#! /usr/bin/env bash
# TRanslation Not Yet Satisfied Built Employing A Chain of Hacks
# This file is merely an adaptation of the standard KDE's scripty's command "update.xml", done by
# mvillarino, an amateur volunteer translator member of the project Trasno (http://www.trasno.net)
# This script is free software, you can use and redistribute it under the same license as the original update.xml

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
    docbookFile=$1 #note: $1 $2 and $3 are full pathed
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
{ #note: $1 $1 and $3 are fullpathed
  #expected return value: a file called temp.xml placed at $home/Traducion/KDE/<branch>/l10n-kde4/ ($prefix)
  #expected side-effects: no environment variabel affected. No other file affected
    docbookFile=$1
    poFile=$2
    moduleDocsDir=$3
    potFile=$4

    intermediate=${prefix}/fleshed.$$.po
    #build a pot file with target texts in "en_US"
    msgen -o $intermediate $potFile
    #merge if with existant translation
    msgmerge -o $intermediate $poFile $intermediate
    #unfuzzy messages
    sed -e "s/^#, fuzzy$//" -i $intermediate
    #replace "ROLES OF TRANSLATORS" by some valid data
# problema coas aspas !!!
   sed -e 's,^msgstr "ROLES_OF_TRANSLATORS",msgstr "<othercredit role=\\"translator\\"><contrib>Proxecto Trasno</contrib></othercredit>",' -i $intermediate
    #replace "CREDITS
   sed -e "s#^msgstr \"CREDIT_FOR_TRANSLATORS\"#msgstr \"<para>Trasno</para>\"#" -i $intermediate
    #now, we can use the process with a full po file
    complete_po_conversion $docbookFile $intermediate $moduleDocsDir

    rm $intermediate
}

function usage()
{
echo "trannybeach.sh [--nodelete] <branch> <lang_lang> [selection [single_catalog]]"
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
  usage
  exit
fi

delete=1
if test "$1" = "--nodelete"; then
  delete=0
  shift
fi


if test "$1" != "trunk" -a "$1" != "branches"; then
  usage
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
#                     continue
                    uncomplete_po_conversion $i $t $bd ${prefix}/templates/docmessages/${m}/${j}.pot
                else
                    complete_po_conversion $i $t $bd
                fi
#             lang=$lang
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
