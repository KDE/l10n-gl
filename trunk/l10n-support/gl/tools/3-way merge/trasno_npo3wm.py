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


try:
    import fallback_import_paths
except:
    import sys
    sys.path.insert(0, "/home/marce/Traducion/KDE/trunk/l10n-support/pology")

from pology.catalog import Catalog
from pology.colors import ColorOptionParser
from pology.fsops import str_to_unicode

def naive3WMerger ( mine, old, yours, acceptDubious, rejectionMark):
  assert isinstance(mine, Catalog),  "parameter «mine» is not a pology Catalog"
  assert isinstance(old, Catalog),   "parameter «old» is not a pology Catalog"
  assert isinstance(yours, Catalog), "parameter «yours» is not a pology Catalog"
  for oldMsg in old:
    oldPosition = old.find(oldMsg)
  
    newPosition = yours.find(oldMsg)
    if newPosition > -1:
      newMsg = yours.__getitem__(newPosition)
      old.__setitem__(oldPosition, newMsg)
      if newMsg.translated or (acceptDubious and not newMsg.untranslated) and (rejectionMark not in newMsg.manual_comment) and newMsg._msgstr != oldMsg._msgstr:
        #print msg._msgstr , new.get(msg)._msgstr , mine.get(msg)._msgstr
        continue
      
    minePosition = mine.find(oldMsg)
    if minePosition > -1:
      mineMsg = mine.__getitem__(minePosition)
      if mineMsg.translated or (acceptDubious and not mineMsg.untranslated) and (rejectionMark not in mineMsg.manual_comment) and mineMsg._msgstr != oldMsg._msgstr:
        #print msg._msgstr , new.get(msg)._msgstr , mine.get(msg)._msgstr
        old.__setitem__(oldPosition, mineMsg)
        continue
  
  # aqui deberiamos procesar as mensaxes de credito
  
  old.header = yours.header  
  #old.sync()
  print old.header.to_string(),
  for msg in old:
    print msg.to_string(),

if __name__ == '__main__':
  usage="%prog% [options] file.po.mine file.po.rOLDREV file.po.rNEWREV"
  desc="does a naive three way merge given three po files"
  ver="'0.1"
  opars = ColorOptionParser (usage=usage, description=desc, version=ver)
  
  opars.add_option( "-m", "--msgmerge",
          action="store", dest="commonPot",
          metavar="POT",
          help="Apply msgmerge on po files before merging using POT as reference.")
  opars.add_option( "-f", "--accept-fuzzy",
        action="store_true", dest="acceptFuzzy", default=False,
        help="Do not discard fuzzy messages for merging into")
  opars.add_option( "-d", "--discarder-message",
        dest="discarderComment", type="string",
        help="Discard for merging any translation unit containing this translator comment")          
  opars.add_option( "-s", "--svn-base",
       action="store_true", dest="svnBase", default=False,
       help="Use as old file the non locally modified version from the working copy (must use with --msgmerge)")          
  
  (options, free_args) = opars.parse_args(str_to_unicode(sys.argv[1:]))             
  
  #ISTO HAI QUE TRABALLALO: SE OPTIONS.BASE TEN O VALOR TRUE, A ORDE DOS PARÁMETROS É MINE, YOURS
  # E NECESARIAMENTE HAI QUE FACER O MERGE_POFILE
  proceed = True
  from os.path import exists
  from tempfile import NamedTemporaryFile
  tmpf = NamedTemporaryFile(prefix="trasno_npo3wm", suffix=".po")
  if len(free_args) == 3 and not options.svnBase:
    for path in free_args:
      if not exists(path):
        proceed = False
        opars.error("There is not file: %path" % path)
  elif len(free_args) == 2 and options.svnBase:
    for path in free_args:
      if not exists(path):
        proceed = False
        opars.error("There is not file: %path" % path)
    import pysvn
    client = pysvn.Client()
    revisions = pysvn.Client().log(free_args[0], limit=500)
    firstNonAutomatedRevision = filter(lambda item: item.author != "scripty",revisions )[0].revision.number
    texto = client.cat(free_args[0], pysvn.Revision( pysvn.opt_revision_kind.number, firstNonAutomatedRevision ))
    del pysvn
    tmpf.write(texto)
    tmpf.seek(0)
  else:
    opars.error("Incorrect number of parameters issued")  

  from pology.merge import merge_pofile
  if options.commonPot and not options.svnBase:
    (mine, old, yours) = [merge_pofile(path, options.commonPot, getcat= True, abort = True) for path in free_args]
  elif options.commonPot and options.svnBase:
    (mine, yours) = [merge_pofile(path, options.commonPot, getcat = True, abort = True) for path in free_args]
    old = merge_pofile(tmpf.name, options.commonPot, getcat = True, abort = True)
  else:
    (mine, old, yours) = [Catalog(path) for path in free_args]
  
  del merge_pofile
  tmpf.close()
  del NamedTemporaryFile
  del exists
  
  if proceed: naive3WMerger ( mine, old, yours, options.acceptFuzzy, options.discarderComment)