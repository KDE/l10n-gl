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
import os.path, subprocess, sys
if not BASE_REPO: # check if THE precondition is met
  subprocess.call(["kdialog", "--title","Unset environment variable",
                   "--error","BASE_REPO not set, please run trasno_firsttime.sh first"])
  sys.exit(1)

discarderComment = "Trasno: rejected"
repo = "aaaaa"
try: #get version
  version = subprocess.check_output(["kdialog", "--title", "Version selection",
                             "--combobox", "Select a version:", "trunk", "stable",
                             "--default", "trunk"])[:-1]
except subprocess.CalledProcessError:
  subprocess.call(["kdialog", "--error", "Exiting because version not chosen"])
  sys.exit(1)
else:
  if version == "stable":
    repo = os.path.join(BASE_REPO, "branches/stable/l10n-kde4/")
  elif version == "trunk":
    repo = os.path.join(BASE_REPO, "trunk/l10n-kde4/")

try: #get repository root
  contributions = subprocess.check_output(["kdialog", "--getexistingdirectory", repo])[:-1]
except subprocess.CalledProcessError:
  subprocess.call(["kdialog", "--error", "Language directory not chosen"])
  sys.exit(1)
else:
  messagesPath = os.path.join(contributions, "messages")
  if not os.path.isdir(messagesPath):
    subprocess.call(["kdialog", "--error", "Bad language directory estructure"])
    sys.exit(1)

try: #get translator's nickname
  tradutor = subprocess.check_output(["kdialog", "--title", "Your nickname",
                                      "--inputbox", "Please enter contributor's nickname, preferably a single word."])[:-1]
except subprocess.CalledProcessError:
  subprocess.call(["kdialog", "--error", "Your nickname is needed"])
  sys.exit(1)
else: # define feedback file name
  import datetime
  entrega = os.path.join(os.path.dirname(contributions),
                         "feedback_to_" + tradutor + "_" + version + "_" + datetime.date.today().isoformat() + ".tar.bz2")
  del datetime
del sys

filesWithRejections = []
#a rather deep-nested and unreadable way to do a simple
#grep -r -l --include="*.po" "^# ${discarderComment}" ${contributions}
import re 
for root, subFolders, files in os.walk(contributions):
    filter(lambda x: not x.endswith(".po"),files)
    for item in (os.path.join(root, name) for name in files if ".svn" not in root):
      with open(item, "r") as ficheiro:
	for line in ficheiro:
	  if re.match( "^#  " + discarderComment + "$", line, re.M):
	    filesWithRejections.append(item)
del re

if len(filesWithRejections) == 0:
  subprocess.call(["kdialog", "--error", "No rejection found"])
  sys.exit(1)
else:
## Let's do a simple 'tar -cjvf  ${entrega} ${filesWithRejections}
  import tarfile
  # First, we create the target file if it does not exists, then whe fill it. 
  if not os.path.exists(entrega):
    file(entrega, 'w').close()
  with tarfile.open(entrega, "w:bz2") as tar:
     for item in filesWithRejections:
       tar.add(item, arcname=os.path.relpath(item,BASE_REPO))

subprocess.call(["kdialog", "--title", "packfeedback.sh", "--msgbox", "packfeedback.py done!"])