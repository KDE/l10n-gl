#! /usr/bin/env python
# -*- coding: UTF-8 -*-
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

import os
BASE_REPO = os.environ.get("BASE_REPO")
del os

discarderComment = "Trasno: rejected"

import os.path, subprocess, sys
if not BASE_REPO: # check if THE precondition is met
  subprocess.call(["kdialog", "--title","Unset environment variable",
                   "--error","BASE_REPO not set, please run trasno_firsttime.sh first"])
  sys.exit(1)

try: #needed to import pology modules
    import fallback_import_paths
except:
  libPath= os.path.join(os.path.expandvars("${BASE_REPO}"), "trunk/l10n-support/pology")
  sys.path.insert(0, libPath)

try: #get repository root
  repo = subprocess.check_output(["kdialog", "--title", "Set language directory",
                                  "--getexistingdirectory", BASE_REPO])[:-1]
except subprocess.CalledProcessError:
  subprocess.call(["kdialog", "--error", "Language directory not chosen"])
  sys.exit(1)
else:
  messagesPath = os.path.join(repo, "messages")
  templatesPath = os.path.join(os.path.dirname(repo), "templates")
  if not os.path.isdir(messagesPath) or not os.path.isdir(templatesPath):
    subprocess.call(["kdialog", "--error", "Bad language directory estructure"])
    sys.exit(1)


try: # get feedback package
 feedback = subprocess.check_output(["kdialog", "--title", "Set feedback package", 
                                     "--getopenfilename", os.path.dirname(repo), 
                                     "application/x-bzip-compressed-tar", 
                                     "application/x-gtar", 
                                     "application/x-bzip2"])[:-1]
except subprocess.CalledProcessError:
  subprocess.call(["kdialog", "--error", "Feedbach package not set"])
  sys.exit(1)

import tarfile
from pology.catalog import Catalog
from pology.merge import merge_pofile
from tempfile import NamedTemporaryFile
# Now, lets unpack file after file, and inject rejections

try:
  with tarfile.open(feedback, "r") as tar:
    for member in tar.getmembers():
      if member.name.startswith("/") or ".." in member.name:
        subprocess.call(["kdialog", "--title","File skipped",
                   "--error", member.name,
                   "will not be processed because of it's suspicious name"])
        continue
      
      fileMine = os.path.join(BASE_REPO, member.name)
      commonPot = os.path.join(os.path.dirname(repo),
                                 "templates",
                                 ficheiroMine[len(repo)+1:] + "t")
      fileFeedback = None
      with tmpf as NamedTemporaryFile(prefix=member.name, suffix=".tmp"):
	tmpf.write(tar.extractfile(member.name).read())
	fileMine = merge_pofile(fileMine, commonPot, getcat=True)
	fileFeedback = merge_pofile(tmpf, commonPot, getcat=True)
      #ficheiroFeedback = tar.extractfile(member.name)
      #VER DE EXTRAIR O FICHEIRO A UN FICHEIRO TEMPORAL CON NOME
      #tmpf = NamedTemporaryFile(prefix=member.name, suffix=".tmp")
      #tmpf.write(ficheiroFeedback.read())
      #cat = Catalog(...)
      #...
      #tmpf = NamedTemporaryFile(prefix="whatever", suffix=".po")
      #cat.sync(writefh=tmpf, force=True)
      #tmpf.close()
      #merge_pofile(tmpf.name, ...)
        for feedbackMsg in feedbackFile:
          if ((not feedbackMsg.untranslated) and (discarderComment in feedbackMsg.manual_comment)):
            mineMsg = fileMine.get(feedbackMsg)
            if not mineMsg:
	      continue
            if (feedbackMsg._msgstr = mineMsg._msgstr):
              mineMsg.fuzzy = feedbackMsg.fuzzy
              if (discarderComment not in mineMsg.manual_comment):
                mineMsg.manual_comment.append(option.discarderComment)
          fileMine.__setitem__(minePosition, mineMsg)
        fileMine.sync()
except IOError, err:
  subprocess.call(["kdialog", "--title","File error",
                   "--error","File processing error"])
  print '%20s  %s' % (feedback, err)
  sys.exit(1)
  # en realidade, quero coller o ficheiro e aplicar un trasno_rejections
  # a ver se cun TarFile.extractfile(member) vai...