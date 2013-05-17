# -*- coding: utf-8 -*-

import Kross,Lokalize,Editor

rejectionText = "Trasno:Rejected"

if Editor.isValid():
  #srcMsg = Editor.entrySource(Editor.currentEntry(), Editor.currentForm())
  Editor.addEntryNote(Editor.currentEntry(), rejectionText)