#! /usr/bin/env bash
# Copyright (c) 2008, Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of Marcelino Villarino Aguiar nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


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