# -*- coding: utf-8 -*-

import Editor,xmlrpclib
import Kross
#import sys,os
#ourPath=([p for p in sys.path if os.path.exists(p+'/mtDialog.ui')]+[''])[0]

proxy = xmlrpclib.ServerProxy("http://api.apertium.org/xmlrpc")
#"http://www.neuralnoise.com:6173/RPC2")

def mtApertiumLangList():
  try:
    #mtLangPairs = proxy.getSupportedLanguagePairs()
    mtLangPairs = proxy.service.getSupportedLanguagePairs()
    print mtLangPairs
    return mtLangPairs
  except xmlrpclib.Fault, fault:
    print fault.faultCode
    print fault.faultString
    return "Failed."

def mtApertiumXmlRpc():
  srcMsg   = Editor.entrySource(Editor.currentEntry(), Editor.currentForm())
  srcLang  = Editor.sourceLangCode()
  tgtLang  = Editor.targetLangCode()
  try:
    return proxy.service.translate( srcMsg, "txt", srcLang, tgtLang, True ,"")
  except xmlrpclib.Fault, fault:
    print fault.faultCode
    print fault.faultString
    return ""

if Editor.isValid():
  res = proxy.translate("This is not a test", "en", "gl")
  print res["translation"]
  print mtApertiumLangList()
  Editor.setEntryTarget(Editor.currentEntry(), Editor.currentForm(), mtApertiumXmlRpc())

#forms = Kross.module("forms")
#mywidget = forms.createWidgetFromUIFile(mypage, ourPath+"/mtDialog.ui")
#if mydialog.exec_loop():
#mydialog.deleteLater()