#!/bin/bash

root=`echo $1|sed "s/\.po//"` 
root=`echo $root|sed "s/\_[a-z]*//"` 
root=`echo $root|sed "s/\_[A-Z]*//"` 

echo $root;
OUTPUT=$root"_gal.po"



cat $1 | ./extrairSTR.perl  | ./port2gal.x > __tmpGZ
cat $1 | ./criarPO.perl __tmpGZ | sed "s/\" \"/\"\"/"  > $OUTPUT

rm __tmp*
