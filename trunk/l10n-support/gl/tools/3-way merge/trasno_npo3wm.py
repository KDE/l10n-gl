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
    import sys
    sys.path.insert(0, "/home/marce/Traducion/KDE/trunk/l10n-support/pology")

from os.path import exists
from pology.catalog import Catalog
from pology.merge import merge_pofile
from pology.colors import ColorOptionParser
from pology.fsops import str_to_unicode
#from pology.stdcmdopt import add_cmdopt_filesfrom

usage="%prog% [options] file.po.mine file.po.rOLDREV file.po.rNEWREV"
desc="does a naive three way merge given three po files"
ver="'0.1"
opars = ColorOptionParser (usage=usage, description=desc, version=ver)

opars.add_option( "-m", "--msgmerge",
        dest="commonPot",
        metavar="POT",
        help="Apply msgmerge on po files before merging using POT as reference.")
opars.add_option( "-f", "--accept-fuzzy",
      action="store_true", dest="acceptFuzzy", default=False,
      help="Do not discard fuzzy messages for merging into")
opars.add_option( "-d", "--discarder-message",
      dest="discarderComment", type="s1tring",
      help="Discard for merging any translation unit containing this translator comment")          
#opars.add_option( "-s", "--svn-base",
      #action="store_true", dest="base", default="False",
      #help="Use as old file the non locally modified version from the working copy")          

(options, free_args) = opars.parse_args(str_to_unicode(sys.argv[1:]))             

# USAR SO PARA o caso de xuntar consigo mesmo
#import pysvn
 #client = pysvn.Client()
#number = pysvn.Client().log("/home/marce/Traducion/KDE/trunk/l10n-kde4/gl/messages/kdelibs/kdelibs4.po", limit=1)[0].revision.number    
 #texto = client.cat("/home/marce/Traducion/KDE/trunk/l10n-kde4/gl/messages/kdelibs/kdelibs4.po", pysvn.Revision( pysvn.opt_revision_kind.number, number )
#import StringIO
#aaa = StringIO.StringIO ( texto )
f#my = Catalog("", readfh = aaa)


if len(free_args) < 3:
  opars.error("Less than three arguments issued")
elif len(free_args) > 3:
  opars.error("More than three arguments issued")
else:
  pass
  for path in free_args:
    if not exists(path):
      opars.error("There is not file: %path" % path)
  #check that a file exists

if options.commonPot:
  (mine, old, yours) = [merge_pofile(path, commonPot) for path in free_args]
else:
  (mine, old, yours) = [Catalog(path) for path in free_args]

for oldMsg in old:
  oldPosition = old.find(oldMsg)
  
  newPosition = yours.find(oldMsg)
  if newPosition > -1:
    newMsg = yours.__getitem__(newPosition)
    old.__setitem__(oldPosition, newMsg)
    if newMsg.translated or (options.acceptFuzzy and not newMsg.untranslated) and (options.discarderComment not in newMsg.manual_comment) and newMsg._msgstr != oldMsg._msgstr:
      #print msg._msgstr , new.get(msg)._msgstr , mine.get(msg)._msgstr
      continue
    
  minePosition = mine.find(oldMsg)
  if minePosition > -1:
    mineMsg = mine.__getitem__(minePosition)
    if mineMsg.translated or (options.acceptFuzzy and not mineMsg.untranslated) and (options.discarderComment not in mineMsg.manual_comment) and mineMsg._msgstr != oldMsg._msgstr:
      #print msg._msgstr , new.get(msg)._msgstr , mine.get(msg)._msgstr
      old.__setitem__(oldPosition, mineMsg)
      continue

# aqui deberiamos procesar as mensaxes de credito

old.header = yours.header  
#old.sync()
print old.header.to_string(),
for msg in old:
  print msg.to_string(),