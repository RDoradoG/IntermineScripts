#!/bin/bash

while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ "$line" != *"#"* ]] ; then
      merge=1
      IFS=$'\t' read -r -a arr <<<"$line"
      if ((${arr[12]} != ${arr[13]})) ; then
         merge=0
      fi
      if [[ "${arr[2]}" != "100.00" ]] ; then
         merge=0
      fi
      if [[ "${arr[10]}" != "0.0" ]] ; then
         merge=0
      fi
      if ((${arr[3]} != ${arr[12]})); then
         merge=0
      fi
      if (($merge == 1)) ; then
        echo -e "${arr[0]}\t${arr[1]}" >> $2
      fi
    fi
done < "$1"
