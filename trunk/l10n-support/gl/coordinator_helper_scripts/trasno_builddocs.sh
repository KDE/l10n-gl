#! /usr/bin/env bash

# Copyright (c) 2011, 2012 Marcelino Villarino Aguiar. All rights reserved.
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

#Please note this script must be run from the language's base directory !!!!

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
echo "transno_builddocs.sh [--nodelete] <branch> <lang_lang> [selection [single_catalog]]"
echo "Please, before using this script, cd the language's parent directory"
}

function process()
{ #process $m_odule $i_docbookFile $t_ranslationFile  $j_equivalentNamesList
module=$1
docbookFile=$2
poFile=$3
equivalentNamesList=$4

bd=`dirname $poFile`
p=`echo $docbookFile | sed -e "s#${prefix}/documentation/${module}/##"`
trans_doc="$bd/../../docs/${module}/$p"
dir=`dirname $trans_doc`
mbase=`dirname $dir`
result=`msgfmt -o /dev/null --statistics $poFile 2>&1`
ret=$?
if test $delete -eq 0 && test "$ret" -ne 0; then
  echo "ERROR: msgfmt $poFile failed. Exiting."
  exit 1
fi
if test "$ret" -ne 0 || echo $result | grep -q untranslated || echo $result | grep -q fuzzy; then
  echo "${module}/${equivalentNamesList}.po: $result"
  uncomplete_po_conversion $docbookFile $poFile $bd ${prefix}/templates/docmessages/${module}/${equivalentNamesList}.pot
else
  complete_po_conversion $docbookFile $poFile $bd
fi

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

# Foreach module and po-file, check if the primordial docbook file exists.
# If so, process it!.

poModulesList=`ls -1R ${prefix}/${lang}/docmessages`

for module in $poModulesList; do
   if [ -d ${prefix}/documentation/${module} ]; then
    for file in `LC_COLLATE=C ls -1r ${prefix}/${lang}/docmessages/$module`; do
        nameLemma=`basename $file .po`
        docbookFile=`echo "$nameLemma" | sed -e "s,_,/,g"`
        # if $file does not contains a /, add it  "/index"
        if ( echo $docbookFile | grep -qv "/" - ); then docbookFile="${docbookFile}/index"; fi
        docbookFile=${prefix}/documentation/${module}/${docbookFile}.docbook
        poFile=${prefix}/${lang}/docmessages/${module}/${file}
        # check if the filename is not in the selection
        case $docbookFile in   #do nothing if the filename is not in the selection 
             *_original.docbook)
             continue
             ;;
             *$selection*)
             ;;
             *)
             continue;;
         esac
        # If a single catalog selected, skip unless this is the one.
        if test -n "$singlecat"; then
          test `basename $poFile | sed "s#/$singlecat.po##"` = $t && continue
        fi
        process $module $docbookFile $poFile $nameLemma
        check_xml
    done
   fi
done
