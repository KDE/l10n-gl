let $items := doc("glosario_adaptado_lokalize_09.tbx")/martif/text/body/termEntry 
for $itemEN in $items/langSet[fn:lang("en")]/ntig/termGrp/term,
    $itemGL in $items/langSet[fn:lang("gl")]/ntig/termGrp/term
where $itemEN/../../../.. = $itemGL/../../../..
return <MAG><PAT>{concat("{", data($itemEN), "}i")}</PAT>
       <CONT>{concat('valid msgstr="', data($itemGL), '"')}</CONT>
       <CTXT>{'hint="', data($itemEN)," = ", data($itemGL),'"')}</CTXT></MAG>