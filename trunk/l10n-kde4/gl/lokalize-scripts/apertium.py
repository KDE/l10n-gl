# -*- coding: utf-8 -*-

import Editor,xmlrpclib
import Kross
import sys,os
ourPath=([p for p in sys.path if os.path.exists(p+'/mtDialog.ui')]+[''])[0]
server = xmlrpclib.ServerProxy("http://api.apertium.org/xmlrpc")

def mtApertiumLangList():
  try:
    mtLangPairs = server.getSupportedLanguagePairs()
  except xmlrpclib.Fault, fault:
    print fault.faultCode
    print fault.faultString
  
  print mtMsg
  return mtLangPairs


def mtApertiumXmlRpc():
  if Editor.isValid(): srcMsg = Editor.entrySource(Editor.currentEntry(), Editor.currentForm())
  
  try:
    mtMsg = server.service.translate( srcMsg, "txt", "en", "gl", "")
  except xmlrpclib.Fault, fault:
    print fault.faultCode
    print fault.faultString
  
  print mtMsg
  return mtMsg

mtApertiumXmlRpc()

forms = Kross.module("forms")
mywidget = forms.createWidgetFromUIFile(mypage, ourPath+"/mtDialog.ui")
if mydialog.exec_loop():
mydialog.deleteLater()