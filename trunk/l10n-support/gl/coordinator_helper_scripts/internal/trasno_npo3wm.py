#! /usr/bin/env python
# -*- coding: UTF-8 -*-
# Copyright (c) 2013 Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with orwithout
# modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer. Redistributions in binary
# form must reproduce the above copyright notice, this list of conditions and
# the following disclaimer in the documentation and/or other materials provided
# with the distribution. Neither the name of Marcelino Villarino Aguiar nor the
# names of its contributors may be used to endorse or promote products derived
# from this software without specific prior written permission.
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
    sys.path.insert(0, "~/Traducion/KDE/trunk/l10n-support/pology")

from pology.catalog import Catalog

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
  
# Trátase de facer unha versión limitada para ser usada por anovar.sh
  if len(sys.argv) != 5:
    sys.exit("Incorrect number of args")
  else:
    from os.path import exists
    if not all(exists(path) for path in sys.argv[1:5]):
      sys.exit("There is not file: %path" % path)
    del exists
    ## Get the paths provided by Subversion.
    for i in range(1, 6)
      print sys.argv[i]
    exit 0
    from pology.merge import merge_pofile
    BASE = merge_pofile(sys.argv[1], options.commonPot, getcat= True,
                      abort = True)
    THEIRS = Catalog(sys.argv[2])
    MINE = merge_pofile(sys.argv[3], options.commonPot, getcat= True,
                        abort = True)
    MERGED = Catalog(sys.argv[4])
    WCPATH = sys.argv[5]
    del merge_pofile

    # necesito a ruta ao pot !!!!!
  discarderComment ="Trasno: rejected"
  
  #naive3WMerger ( MINE, BASE, THEIRS, True, discarderComment)