 /bin/bash
#$ -q all.q
#$ -cwd
#$ -pe threads 2

CMD=`blastp -db Creinhardtii_ALL_proteins.fa -query uniprot-organism%3A_chlamydomonas+reinhardtii_.fasta -evalue 1e-5 -num_threads 2 -outfmt '7 std qlen slen' > All_result_merge`
$CMD
