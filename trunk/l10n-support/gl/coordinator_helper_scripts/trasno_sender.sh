#! /usr/bin/env bash
#Este script serve para engadir e entregar o traballo a KDE.

#TODO: Resolver conflitos (?)
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


if [ $# -lt 2 ]; then
      echo "Usage: sender.sh <version> <message>" >&2
      echo "version is one in stable or trunk" >&2
#       echo "If message is a text with several words, enclose it in quotes (\"\")" >&2
   exit 1
fi

if [ -z "$BASE_REPO" ] ; then
   echo "BASE_REPO not set, please run trasno_firsttime.sh first" >&2
   exit 2
fi

case "$1" in
   stable)
      repo=${BASE_REPO}/branches/stable/l10n-kde4/
      shift
      ;;
   trunk)
      repo=${BASE_REPO}/trunk/l10n-kde4/
      shift
      ;;
   *)
      echo "Usage: sender.sh <version> <message>"
      echo "branch is one in stable or trunk"
      exit 2
    ;;
esac

if [ `svn status ${repo}gl/ | grep "^\?" | cut -d" " -f8 | wc -l` -ne  0 ] ; then
        svn add `svn status ${repo}gl/  | grep "?" | cut -d" " -f8`
fi
 
svn commit ${repo}gl/ -m"$@"
