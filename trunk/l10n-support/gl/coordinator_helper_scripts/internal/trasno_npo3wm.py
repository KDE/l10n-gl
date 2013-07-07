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
  sys.path.insert(0, "/home/test/Traducion/KDE/trunk/l10n-support/pology")

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
  
  # Put the paths as provided by svn update --quiet --diff3-cmd ${merger} --non-interactive ${BASE_REPO}/${galla}/${code} into the right (tm) variables
  #            gl/messages/playground-base/.svn/tmp/svn-WXB1HK (MINE)
  #            gl/messages/playground-base/.svn/text-base/file.po.svn-base (OLDER)
  #            gl/messages/playground-base/.svn/tmp/text-base/file.po.svn-base (YOURS)
  from pology.merge import merge_pofile
  import os.path
  #poido coller o nome o ficheiro de sys.argv[-2] (vai despois de .svn/text-base, e hai que quitarlle un .svn-base final)
  nomeCompletoFicheiroMINE = os.path.abspath(sys.argv[-3])
  nomeCompletoFicheiroBASE = os.path.abspath(sys.argv[-2])
  nomeCompletoFicheiroTHEIRS = os.path.abspath(sys.argv[-1])
  
  nomeTemplate = os.path.basename(os.path.splitext(nomeCompletoFicheiroBASE)[0])+"t"  
  nomeModuloTMP   = os.path.dirname(os.path.dirname(os.path.commonprefix([nomeCompletoFicheiroBASE, nomeCompletoFicheiroMINE])))
  modulo = os.path.basename(nomeModuloTMP)
  seccion = os.path.basename(os.path.dirname(nomeModuloTMP))
  base = os.path.expandvars("${BASE_REPO}/${galla}") 
  commonPot = os.path.join(base,"templates",seccion, modulo, nomeTemplate)
  
  MINE = merge_pofile(sys.argv[-3], commonPot, getcat= True,
                      abort = True)
  BASE = merge_pofile(sys.argv[-2], commonPot, getcat= True,
                    abort = True)
  THEIRS = Catalog(sys.argv[-1])
  
  del merge_pofile

  discarderComment ="Trasno: rejected"
  
  naive3WMerger ( MINE, BASE, THEIRS, True, discarderComment)
  # After performing the merge, this script needs to print the contents
  # of the merged file to stdout.  Do that in whatever way you see fit.
  # Return an errorcode of 0 on successful merge, 1 if unresolved conflicts
  # remain in the result.  Any other errorcode will be treated as fatal.