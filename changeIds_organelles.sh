#!/bin/bash

oldids=`grep ">" $1`
while IFS='' read -r lineId || [[ -n "$lineId" ]]; do
  IFS=$'>' read -r -a oldID <<<"$lineId"
  newid=`grep ${oldID[1]} $2 | grep -m 1 CDS | cut -f 9 -d$'\t' | cut -f 2 -d';' | cut -f 2 -d'='`
  echo "sed -if 's/${oldID[1]}/$newid/' $1"
done <<< "$oldids"

