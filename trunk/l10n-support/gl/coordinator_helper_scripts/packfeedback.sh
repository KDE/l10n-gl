#! /usr/bin/env bash
# Copyright (c) 2013 Marcelino Villarino Aguiar
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
 kdialog --title "Unset environment variable" \
         --error "BASE_REPO not set, please run trasno_firsttime.sh first"
 exit 1
fi

declare version
declare contributions
 
#OK, this is a piece of shit...
declare -r  discarderComment="Trasno: rejected"
#end of shit

version=$(kdialog --title "Version selection" \
        --combobox "Select a version:" "trunk" "stable" --default "trunk") \
        || (kdialog --error "Exiting because version not chosen" && exit 1)
repo=$(case ${version} in
            stable)
              echo ${BASE_REPO}/branches/stable/l10n-kde4/
              ;;
            trunk)
              echo ${BASE_REPO}/trunk/l10n-kde4/
            ;;
            esac
          )

contributions=$(kdialog --getexistingdirectory ${repo}) \
              || (kdialog --error "Language directory not chosen" && exit 1)

declare -r tradutor=$(kdialog --title "Your nickname" \
                        --inputbox "Please enter your nickname, preferably a single word.")

declare -r entrega="feedback_to_"${tradutor}_${version}_`date +%F`.tar.bz2
declare -r ficheiros=$(grep -r -l --include="*.po" "^# ${discarderComment}" ${contributions})
if [ -z ${ficheiros} ]; then
  kdialog --error "Found no file containing the rejection mark (${discarderComment})"
else
  tar -cjvf  ${entrega} ${ficheiros}
fi


kdialog --title "packfeedback.sh" --msgbox "packfeedback.sh done!"