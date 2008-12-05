#!/usr/bin/perl -w
# usage: pot2po.perl < file.po > file.pot
# flush contents of msgstr's, and fuzzy marks.
# done by mvillarino based on the script estrairmsgstr.perl
# this script is free software, distributed under the terms of the BSD license.
# Copyright (c) 2008, Marcelino Villarino Aguiar
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# Neither the name of the Marcelino Villarino Aguiar nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

$found = 0;
$header = 1;
while ($line = <STDIN>) {

chomp $line;

  if ( ($line =~ /^msgid/) || ($line=~ /^msgctxt/) || ($line eq "") || ($line =~ /^\#/) )   { $found = 1; }
  if ( ($line=~ /^\#/) ) {
        $line=~ s/#, fuzzy,/#,/g;
        $line=~ s/#, fuzzy$//g;
  }

  if ($line =~ /^msgstr /) {
    if ($header) {
        print "# Galician translations for PACKAGE package.\n";
        print "# Copyright (C) 2008\n";
        print "# This file is distributed under the same license as the PACKAGE package.\n";
        print "# marce <marce\@users.sourceforge.net>, 2008.\n";
        print "#\n";
        print "msgid \"\"\n";
        print "msgstr \"\"\n";
        print "\"Project-Id-Version: PACKAGE VERSION\\n\"\n";
        print "\"Report-Msgid-Bugs-To: \\n\"\n";
        print "\"POT-Creation-Date: YEAR-MO-DA HO:MI+ZONE\\n\"\n";
        print "\"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\n\"\n";
        print "\"Last-Translator: FULL NAME <EMAIL\@ADDRESS>\\n\"\n";
        print "\"Language-Team: LANGUAGE <LL\@li.org>\\n\"\n";
        print "\"MIME-Version: 1.0\\n\"\n";
        print "\"Content-Type: text/plain; charset=UTF-8\\n\"\n";
        print "\"Content-Transfer-Encoding: 8bit\\n\"\n";
        print "\"Plural-Forms: nplurals=INTEGER;plural=EXPRESSION;\\n\"\n";
        $header = 0;
    }
    else {
        print "msgstr \"\"\n";
    }
    $found = 0;
  }

  if ($line =~ /^msgstr\[0\]/) {
    print "msgstr[0] \"\"\n";
    $found=0;
  }

  if ($line =~ /^msgstr\[1\]/) {
    print "msgstr[1] \"\"\n";
    $found=0;
  }

  if ($found and not $header) { print "$line\n"; }
}
