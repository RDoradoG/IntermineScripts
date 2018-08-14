ne='0'
putted='0'
tentative='0'
ChooseOneID=""
ChooseOnePrev=""
maxPerDif="80"
minPerDif="10"
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ "$line" != *"#"* ]] ; then
      if [[ "$newline" = "1" ]] ; then
        newline='0'
        putted='0'
        tentative='0'
        ChooseOneID=""
        ChooseOnePrev=""
        maxPerDif="80"
        minPerDif="10"
      fi
      mergeTotal=1
      merge=1
      IFS=$'\t' read -r -a arr <<<"$line"
      if ((${arr[12]} != ${arr[13]})) ; then
         mergeTotal=0
      fi
      if [[ "${arr[2]}" != "100.00" ]] ; then
         mergeTotal=0
      fi
      if ((${arr[12]} != ${arr[3]})) ; then
         mergeTotal=0
      fi
      if (($mergeTotal == 1)) ; then
        echo -e "${arr[0]}\t${arr[1]}" >> $2
        putted='1'
      else
        if [ $(echo "${arr[2]} < ${maxPerDif}" | bc) = 1 ]; then
          merge=0
        fi
        if ((${arr[12]} > ${arr[3]})) ; then
          value=$((arr[12] - arr[13]))
          if ((value > 0)) ; then
            percent=$((arr[12] * 100 / value))
          else
            percent="0"
          fi
        else
          value=$((arr[13] - arr[12]))
          if ((value > 0)) ; then
            percent=$((arr[13] * 100 / value))
          else
            percent="0"
          fi
        fi
        if ((${percent} > ${minPerDif})) ; then
          merge=0
        fi
        if (($merge == 1)) ; then
          minPerDif="${percent}"
          maxPerDif="${arr[2]}"
          ChooseOneID="${arr[0]}"
          ChooseOnePrev="${arr[1]}"
          tentative='1'
        fi
      fi
    else
      if [[ "$putted" = "0" ]] ; then
        if [[ "$tentative" = "1" ]] ; then
          echo -e "${ChooseOneID}\t${ChooseOnePrev}" >> $2
          putted='1'
        fi
      fi
      newline='1'
    fi
done < "$1"
