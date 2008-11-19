#!/bin/bash
#Concatenate files passed as parameters to stdout in an horizontal way.
#This is, file1 as column1 .. fileN as columnN
#Check all files received as parameters exists
#and get the bigest number of lines in files
LINES=0
BIGGEST_LINE=0
for FILE in $@
do
#Check file exists
if [ ! -f $FILE ] ; then
echo ERROR:
file $FILE
exit -1
else
#Check file is text
wc -l $FILE 2>/dev/null 1>&2
if [ $? -ne 0 ] ; then
echo ERROR:
file $FILE
exit -1
fi
fi
#Check this file is bigger
LINES=`cat $FILE | wc -l`
if [ $LINES -gt $BIGGEST_LINE ] ; then
BIGGEST_LINE=$LINES
fi
done
#Work from line 1 to BIGGEST_LINE
LINE=1
while true
do
  LINE=`expr $LINE + 1`
  #Check job done
  if [ $LINE -gt $BIGGEST_LINE ] ; then
    exit 0
  fi
  #Work from file 1 to file N
  echo -n "msgid \""
  for FILE in $@
  do
    #Concatenate line if applicable
    if [ $LINE -gt `cat $FILE | wc -l` ] ; then
      continue
    else
      echo `head -"$LINE" $FILE | tail -1`\"
      echo -n "msgstr \""
    fi
  done
  echo "\""
done
