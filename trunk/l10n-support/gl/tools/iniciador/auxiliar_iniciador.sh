#! /usr/bin/env bash
echo "I'm here"
po=$1
pot=$2
compendium=$3
LINES=`wc -l $po | cut -f1 -d" "`
LINE=1
echo $LINES
while [ $LINE -le $LINES ]
do
    echo "$LINE of $LINES"
    pofile=`head -"$LINE" ${po} | tail -1`
    potfile=`head -"$LINE" ${pot} | tail -1`
    echo "Will merge newer ${potfile} with ${pofile} using ${compendium}"
    msgmerge $pofile $potfile -o $pofile --previous --silent -C $compendium
    LINE=`expr $LINE + 1`
done