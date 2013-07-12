#! /usr/bin/env bash
# Copyright (c) 2013 Marcelino Villarino Aguiar. All rights reserved.
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

if [ -z "$BASE_REPO" ] ; then
 kdialog --title "Unset environment variable" \
         --error "BASE_REPO not set, please run trasno_firsttime.sh first"
 exit 1
fi

declare version
version=$(kdialog --title "Version selection" \
         --combobox "Select a version:" "trunk" "stable" --default "trunk") \
        || (kdialog --error "Exiting because version not chosen" && exit 1)

declare repo=$(case ${version} in
                 stable)
                   echo ${BASE_REPO}/branches/stable/l10n-kde4
                   ;;
                 trunk)
                   echo ${BASE_REPO}/trunk/l10n-kde4
                   ;;
               esac
               )

declare possibleLang
possibleLang=$(kdialog --getexistingdirectory ${repo}) \
             || (kdialog --error "Language directory not chosen" && exit 1)

declare -r svnUrl=$(svn info ${possibleLang} \
                  | grep "^Repository Root: " \
                  | cut -d" " -f3 )

case ${svnUrl} in
  svn+ssh://svn@svn.kde.org/home/kde*)
    if [ $(svn status ${possibleLang} | grep "^\?" | cut -d" " -f8 | wc -l) \
         -ne  0 ] ; then
      svn add `svn status ${possibleLang}  | grep "^\?" | cut -d" " -f8`
    fi
    svn commit ${possibleLang}/ --editor-cmd kwrite
    ;;
  svn://anonsvn.kde.org/home/kde*)
    #aqui a parte de empaquetar 
    declare -r tradutor=$(kdialog --title "Your nickname" \
                        --inputbox "Please enter your nickname, preferably a single word.")
    if [ -z ${tradutor} ]; then
      kdialog --title "Nickname needed" --error "A nickname is required in order to proceed"
      exit 1
    fi
    declare -r entrega="entrega_"${tradutor}_${version}_`date +%F`.tar.bz2
    declare -r ficheiros=$(svn status ${possibleLang} \
                         | grep [MC?] \
                         | cut -d" " -f8 \
                         | sed -e s:^"${possibleLang}/":: )
    tar -cjvf  ${entrega} -C ${possibleLang} ${ficheiros}
    ;;
  *)
    kdialog --title "Unexpected repository" \
            --error "Given directory does not report any expected repository root."
    exit 1
    ;;
esac
kdialog --title "trasno_submit.sh" --msgbox "trasno_submit.sh done!"