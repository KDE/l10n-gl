#! /usr/bin/env bash

# usage: trasno_firsttime.sh <lang> <user>
# fai a configuración inicial dun proxecto de tradución, para ser empregado por
# tradutores, ou coordinadores (acede a anonsvn.kde.org ou a svn+ssh)

# Copyright (c) 2008, 2011, 2013 Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
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

function getThem()
{
  local -r url=$1
  local -r lang=$2
  
  for place in trunk/l10n-kde4/{scripts,templates,${lang}} trunk/l10n-support/{${lang},pology} branches/stable/l10n-kde4/{scripts,templates,${lang}}; do
    if [ -d ${BASE_REPO}/${place} -a ! -d ${BASE_REPO}/${place}/.svn ]; then
        echo ${BASE_REPO}/${place}
        svn checkout ${url}/${place} ${BASE_REPO}/${place}
    else
        echo "non: ${BASE_REPO}/${place}"
    fi
  done
}

if [ ! `cat $HOME/.bashrc | grep '$PATH' | grep '$BASE_REPO' | wc -m` == 0 ]; then
    echo 'Environment variable $BASE_REPO is already present into your .bashrc'
    echo 'This may indicate that trasno_firsttime.sh has already been run for you!!!'
    exit 2
fi

declare code=`kdialog --title "Language code" --inputbox "Please enter the language code you want to translate to (e.g. \"gl\" or \"x-test\")"`
declare user=`kdialog --title "KDE developer identity" --inputbox "What is you KDE identity?"`

declare -r devSvn="svn+ssh://svn@svn.kde.org/home/kde"
declare -r usrSvn="svn://anonsvn.kde.org/home/kde"
declare -xr BASE_REPO=$HOME/Traducion/KDE
declare -xr PATH=$BASE_REPO/trunk/l10n-support/pology/scripts:$BASE_REPO/trunk/l10n-support/gl/coordinator_helper_scripts:$PATH

# #criamos os cartafoles base
#creamos os cartafoles segundo se reflicte na estrutura citada en axuda.txt. Imos pór só o esencial. Comente as liñas nos desexadas.
mkdir -p $BASE_REPO/trunk/l10n-kde4/{${code},templates,scripts}
mkdir -p $BASE_REPO/branches/stable/l10n-kde4/{${code},templates,scripts}
mkdir -p $BASE_REPO/trunk/l10n-support/{${code},pology}

#agora os svn checkout
if [ user ]; then
  if [ -f "${HOME}/.ssh/${user}_rsa" ]; then
    ssh_key=${user}"_rsa"
  elif [ -f "${HOME}/.ssh/${user}_dsa" ]; then
    ssh_key=${user}"_dsa"
  else 
    echo "There is no ${HOME}/.ssh/${ssh_key}, exiting"
    exit 1
  fi
  if [ -x "/usr/bin/ksshaskpass" ]; then
    export SSH_ASKPASS=/usr/bin/ksshaskpass
  fi
  ssh-add ${HOME}/.ssh/${ssh_key} < /dev/null
  getThem ${devSvn} ${code}
else
  echo "WARNING: Using anonsvn"
  getThem ${usrSvn} ${code}
fi

#engadimos ao final de .bashrc as variábeis de entorno precisas
echo "export BASE_REPO=$HOME/Traducion/KDE" >> $HOME/.bashrc
echo 'export PATH=$BASE_REPO/trunk/l10n-support/pology/scripts:$BASE_REPO/trunk/l10n-support/gl/coordinator_helper_scripts:$PATH' >> $HOME/.bashrc
