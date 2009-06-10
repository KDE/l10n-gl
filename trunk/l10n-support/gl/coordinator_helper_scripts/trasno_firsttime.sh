#! /usr/bin/env bash

# usage: trasno_firsttime.sh <lang> <user>
# fai a configuración inicial dun proxecto de tradución, para ser empregado por
# tradutores, ou coordinadores (acede a anonsvn.kde.org ou a svn+ssh)

# Copyright (c) 2008, Marcelino Villarino Aguiar
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

if [ $# -ne 2 ] ; then
   echo "Usage: trasno_firsttime.sh lang_code [svnUser]"
   exit 2
else
   code=$1
   user=$2
fi

#primeiro, modifica o .bashrc, se non o foi xa.
if [ ! `cat $HOME/.bashrc | grep '$PATH' | grep '$BASE_REPO' | wc -m` == 0 ]; then
    echo 'Environment variable $BASE_REPO is already present into your .bashrc'
    echo 'This may indicate that trasno_firsttime.sh has already been run for you!!!'
    exit 2
fi

#engadimos ao final de .bashrc as variábeis de entorno precisas
export BASE_REPO=$HOME/Traducion/KDE
echo "export BASE_REPO=$HOME/Traducion/KDE" >> $HOME/.bashrc
echo 'export PATH=$BASE_REPO/trunk/l10n-support/pology/scripts:$BASE_REPO/trunk/l10n-support/gl/coordinator_helper_scripts:$PATH' >> $HOME/.bashrc

# #criamos os cartafoles base
# if [ ! -d $HOME/Traducion/KDE ]; then mkdir -p $HOME/Traducion/KDE; fi

#creamos os cartafoles segundo se reflicte na estrutura citada en axuda.txt. Imos pór só o esencial. Comente as liñas nos desexadas.
mkdir -p $BASE_REPO/trunk/l10n-kde4/{$code,scripts,templates}
mkdir -p $BASE_REPO/trunk/l10n-kde4/documentation
mkdir -p $BASE_REPO/trunk/l10n-support/{$code,pology,scripts}
mkdir -p $BASE_REPO/trunk/l10n-support/templates
mkdir -p $BASE_REPO/branches/stable/l10n-kde4/{$code,templates,scripts}

#agora os svn checkout
if [ $# -eq 2 ]; then
    echo "Will try to checkout svn(+ssh) with user $user"
    for place in trunk/{l10n-kde4,l10n-support}/{scripts,templates,$code,pology,documentation}; do
        if [ -d $BASE_REPO/$place -a ! -d $BASE_REPO/$place/.svn ]; then
            echo $BASE_REPO/$place
            svn checkout svn+ssh://${user}@svn.kde.org/home/kde/$place $BASE_REPO/$place
        else
            echo "non: " $BASE_REPO/$place
        fi
    done
    for place in branches/stable/l10n-kde4/{scripts,templates,$code}; do
        if [ -d $BASE_REPO/$place -a ! -d $BASE_REPO/$place/.svn ]; then
            echo $BASE_REPO/$place
            svn checkout svn+ssh://${user}@svn.kde.org/home/kde/$place $BASE_REPO/$place
        else
            echo "non: " $BASE_REPO/$place
        fi
    done
fi
if [ $# -eq 1 ]; then
    echo "Will try to checkout via anonsvn"
    for place in trunk/{l10n-kde4,l10n-support}/{scripts,templates,$code,pology,documentation}; do
        if [ -d $BASE_REPO/$place -a ! -d $BASE_REPO/$place/.svn ]; then
            echo $BASE_REPO/$place
            svn checkout svn://anonsvn.kde.org/home/kde/$place $BASE_REPO/$place
        else
            echo "non: " $BASE_REPO/$place
        fi
    done
    for place in branches/stable/l10n-kde4/{scripts,templates,$code}; do
        if [ -d $BASE_REPO/$place -a ! -d $BASE_REPO/$place/.svn ]; then
            echo $BASE_REPO/$place
            svn checkout svn://anonsvn.kde.org/home/kde/$place $BASE_REPO/$place
        else
            echo "non: " $BASE_REPO/$place
        fi
    done
fi
