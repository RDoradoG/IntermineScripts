#!/bin/bash
# $1 Annotation file
# $2 Defline file
# $3 Aspect file
# $4 Obo file
# $5 Result file
# $6 Taxon Id --- Chlamydomona Reinhardtii: 3055

firtsLine="0"
today=`date +%Y%m%d`
convertedLine=`sed 's/\t\t/\tx\t/g' $1 | sed 's/\t\t/\tx\t/g' > tmp_$1`
while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ "$firtsLine" != "0" ]] ; then
    IFS=$'\t' read -r -a columns <<<"$line"
    geneID="${columns[2]}.v5.5"
    seacrh=`grep ${columns[2]} $2`
    defline=""
    if [[ "$seacrh" != "" ]] ; then
      while IFS='' read -r lineId || [[ -n "$lineId" ]]; do
        IFS=$'\t' read -r -a tabulationSplit <<<"$lineId"
        defline="${tabulationSplit[2]}"
      done <<< "$seacrh"
    fi
    IFS=$',' read -r -a goIds <<<"${columns[9]}"
    for goId in "${goIds[@]}"
    do
        if [[ "$goId" != "x" ]] ; then
          aspect=`grep -A 3 "id: ${goId}" $4 | grep "namespace:" | cut -f 2 -d" "`
          aspect=`grep "${aspect}" $3 |  cut -f 2 -d$'\t'`
          newline="phycomine\t${geneID}\t${geneID}\t\t${goId}\t\tIC\t\t${aspect}\t${defline}\t${geneID}\tgene\ttaxon:${6}\t${today}\tphycomine"
          echo -e "$newline" >> $5
        fi
    done
  else
    firtsLine="1"
  fi
done < "tmp_$1"
remove=`rm tmp_$1`
