#! /usr/bin/env python
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


try:
    import fallback_import_paths
except:
  import os.path
  libPath= os.path.join(os.path.expandvars("${BASE_REPO}"), "trunk/l10n-support/pology")
  import sys
  sys.path.insert(0, libPath)
  del os.path

from os.path import exists
from pology.catalog import Catalog
from pology.merge import merge_pofile
from pology.colors import ColorOptionParser
from pology.fsops import str_to_unicode
#from pology.stdcmdopt import add_cmdopt_filesfrom

usage="%prog% [options] file.po file.po.feedback"
desc="injects rejection marks into a po file"
ver="0.1"
opars = ColorOptionParser (usage=usage, description=desc, version=ver)

opars.add_option( "-m", "--msgmerge",
        dest="commonPot",
        metavar="POT",
        help="Apply msgmerge on po files before merging using POT as reference.")
opars.add_option( "-d", "--discarder-message",
      dest="discarderComment", type="string",
      help="The comment used as rejection mark.")          

(options, free_args) = opars.parse_args(str_to_unicode(sys.argv[1:]))             
               
if len(free_args) < 2:
  opars.error("Less than two arguments issued")
elif len(free_args) > 2:
  opars.error("More than two arguments issued")
else:
  pass
  for path in free_args:
    if not exists(path):
      opars.error("There is not file: %path" % path)
  #check that a file exists

if options.commonPot:
  (mine, feedbackFile) = [merge_pofile(path, commonPot) for path in free_args]
else:
  (mine, feedbackFile) = [Catalog(path) for path in free_args]

for feedbackMsg in feedbackFile:
  if (not feedbackMsg.untranslated) and (options.discarderComment in feedbackMsg.manual_comment):
    minePosition = mine.find(feedbackMsg)
    if minePosition = -1:
      continue
    mineMsg = mine.__getitem__(minePosition)
    if (feedbackMsg._msgstr = mineMsg._msgstr):
      mineMsg.fuzzy = feedbackMsg.fuzzy
      if (options.discarderComment not in mineMsg.manual_comment):
        mineMsg.manual_comment.append(option.discarderComment)
    mine.__setitem__(minePosition, mineMsg)

#mine.sync()
print mine.header.to_string(),
for msg in mine:
  print msg.to_string(),