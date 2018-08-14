#!/bin/bash
filename_original="$2"
filename="${filename_original}_gff3.gff3"
inGen="0"
while IFS='' read -r line || [[ -n "$line" ]]; do
  if [[ "$line" = "##FASTA"* ]] ; then
    filename="${filename_original}_genome.fa"
  fi
  if [[ "$line" = ">"* ]] ; then
    if [[ "$inGen" = "1" ]] ; then
      filename="${filename_original}_proteins.fa"
      inGen="2"
    fi
    if [[ "$inGen" = "0" ]] ; then
      inGen="1"
    fi
  fi
  if [[ "$line" != "#"* ]] ; then
    echo "$line" >> "$filename"
  fi
done < "$1"
