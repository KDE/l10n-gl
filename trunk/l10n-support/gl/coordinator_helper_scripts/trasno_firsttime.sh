#! /usr/bin/env bash

# usage: trasno_firsttime.sh <lang>
# fai a configuración inicial dun proxecto de tradución, para ser empregado por
# tradutores, non coordinadores (acede a anonsvn.kde.org)
if [ $# -lt 1 ] ; then
   echo "Usage: trasno_firsttine.sh lang_code"
   exit 2
else
   code=$1
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

#agora os svn checkout
for place in trunk/{l10n-kde4,l10n-support}/{scripts,templates,$code,pology,documentation}; do
    if [ -d $BASE_REPO/$place -a ! -d $BASE_REPO/$place/.svn ]; then
        echo $BASE_REPO/$place
#         svn checkout svn://anonsvn.kde.org/home/KDE/$place $BASE_REPO/$place
    else
        echo "non: " $BASE_REPO/$place
    fi
done