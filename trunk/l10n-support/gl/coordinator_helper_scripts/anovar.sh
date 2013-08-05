#! /usr/bin/env bash
# -*- coding: UTF-8 -*-
#Este script serve para actualizar os repositorios, resolver os conflitos entre
#versións, procesar os orfos e algunha cousa máis.
#LER O FICHEIRO AXUDA.TXT ANTES DE UTILIZAR!!!!!

# Copyright (c) 2008, 2010, 2013 Marcelino Villarino Aguiar
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

# function resolveConflicts()
# {
#   local -r repository=$1
#   local -r commonPath=`dirname ${repository}`
#   local -r marca="mine"
# 
#   for ficheiro in `svn status ${repository} | grep "^C " | cut -d" " -f8`;do
#     declare directorio=`dirname ${ficheiro}`
#     declare  nome=`basename ${ficheiro} ."${marca}"`
#     kdialog -title "anovar.sh" --passivepopup "Solving conflicts and forwarding: ${directorio}/${nome}" 1
#     svn resolve --accept mine-full ${directorio}/${nome}
#     ${commonPath}/scripts/merge.sh ${directorio}/${nome} ${commonPath}/templates${directorio##"${commonPath}/${lang}"}/${nome}t
#   done    
# }

if [ -z "$BASE_REPO" ] ; then
   kdialog --title "Unset environment variable" --error "BASE_REPO not set, please run trasno_firsttime.sh first"
   exit 1
fi

if [ $# -ne 0 ]; then
   kdialog --title "anovar.sh usage error" --error "This script accepts no parameters" >&2
   exit 1
fi

declare -r code=`kdialog --title "Language code" --inputbox "Please enter the language code you want to update (e.g. \"gl\" or \"x-test\")"`
declare -r user=`kdialog --title "KDE developer identity" --inputbox "What is you KDE identity?"` 
declare ssh_key=""
if [ "${user}" != "" ]; then
  if [ -f "${HOME}/.ssh/${user}_rsa" ]; then
      ssh_key=${user}"_rsa"
  elif [ -f "${HOME}/.ssh/${user}_dsa" ]; then
      ssh_key=${user}"_dsa"
  else
      kdialog --title "anovar.sh" --sorry "There is neither ${HOME}/.ssh/${user}_rsa, nor ${HOME}/.ssh/${user}_dsa, exiting"
      exit 1
  fi
  if [ -x "/usr/bin/ksshaskpass" ]; then
    export SSH_ASKPASS=/usr/bin/ksshaskpass
  fi
  ssh-add ${HOME}/.ssh/${ssh_key} < /dev/null
fi

declare -r merger=${BASE_REPO}/trunk/l10n-support/gl/coordinator_helper_scripts/internal/trasno_npo3wm.py

#REPOSITORIES UPDATES
for lugar in {trunk/l10n-kde4,branches/stable/l10n-kde4}/{scripts,templates} trunk/l10n-support/pology; do #anovamos
    if [ -d ${BASE_REPO}/${lugar}/.svn ]; then
        kdialog --title "anovar.sh" --passivepopup "Updating: ${lugar}" 3
        svn update --non-interactive --quiet --accept theirs-full ${BASE_REPO}/${lugar}
    fi
done

declare -x galla
for galla in trunk/l10n-kde4 branches/stable/l10n-kde4 trunk/l10n-support; do #anovamos as traducións
    if [ -d ${BASE_REPO}/${galla}/${code}/.svn ]; then
        kdialog --title "anovar.sh" --passivepopup "Updating: ${galla}/${code}" 3
         svn update --non-interactive --quiet --accept mine-full ${BASE_REPO}/${galla}/${code}
#          resolveConflicts ${BASE_REPO}/${galla}/${code}
#           svn update --quiet --diff3-cmd ${merger} --non-interactive ${BASE_REPO}/${galla}/${code}
    fi
done
unset galla
kdialog --title "anovar.sh" --passivepopup "END OF REPOSITORIES UPDATES, going to second stage" 2

for galla in trunk branches/stable; do
    if [ -x ${BASE_REPO}/${galla}/l10n-kde4/scripts/process_orphans.sh ]; then #procésanse os orfos e vese cais po non teñen pot
        kdialog -title "anovar.sh" --passivepopup "Processing orphans of ${galla}" 5
        cd ${BASE_REPO}/${galla}/l10n-kde4/ #ISTO DEBERÏA IR NUNHA SUBSHELL
        ${BASE_REPO}/${galla}/l10n-kde4/scripts/process_orphans.sh &> /dev/null
    fi
    if [ -x ${BASE_REPO}/${galla}/l10n-kde4/scripts/find_po_without_pot.sh ]; then
        kdialog -title "anovar.sh" --passivepopup "Checking for po files without associated po file on ${galla}" 5
        ${BASE_REPO}/${galla}/l10n-kde4/scripts/find_po_without_pot.sh ${code}
    fi
done
kdialog --title "anovar.sh" --msgbox "Anovar.sh done!"