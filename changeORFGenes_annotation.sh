#!/bin/bash
## $1 .xml file
## $2 merge file
## $3 new file

ingene='0'
allIds=()
resultLines="$(wc -l $1)"
IFS=$' ' read -r -a totalLinesSplited <<<"$resultLines"
totalLines="${totalLinesSplited[0]}"
countLine='0'
oldPercent='100'
tabulations=''
while IFS='' read -r line || [[ -n "$line" ]]; do
  percent=$[countLine * 100 / totalLines]
  countLine=$[countLine + 1]
  if [[ "$percent" != "$oldPercent" ]] ; then
    echo "$percent %"
    oldPercent="$percent"
  fi
  save='1'
  if [[ "$line" = *"<entry"* ]] ; then
    allIds=()
  fi
  if [[ "$line" = *"<gene>"* ]] ; then
    IFS=$'<' read -r -a numberOFTab <<<"$line"
    tabulations="${numberOFTab[0]}"
    ingene='1'
  fi
  if [[ "$line" = *"</gene"* ]] ; then
    for id in "${allIds[@]}"
    do
       echo -e "${tabulations}\t<name type=\"ORF\">${id}</name>" >> $3
    done
    ingene='0'
  fi
  if [[ "$line" = *"<accession"* ]] ; then
    IFS=$'>' read -r -a firstSplit <<<"$line"
    IFS=$'<' read -r -a lastSplit <<<"${firstSplit[1]}"
    accession="|${lastSplit[0]}|"
    result=`grep $accession $2`
    if [[ "$result" != "" ]] ; then
      while IFS='' read -r lineId || [[ -n "$lineId" ]]; do
        IFS=$'\t' read -r -a tabulationSplit <<<"$lineId"
        IFS=$'\r' read -r -a carrieSplit <<<"${tabulationSplit[1]}"
        IFS=$'\n' read -r -a newlineSplit <<<"${carrieSplit[0]}"
        allIds+=("${newlineSplit[0]}")
      done <<< "$result"
    fi
  fi
  if [[ "$ingene" = "1" ]] ; then
    if [[ "$line" = *'<name type="ORF"'* ]] ; then
      save='0'
    fi
  fi
  if [[ "$save" = "1" ]] ; then
    echo "$line" >> $3
  fi
done < "$1"
