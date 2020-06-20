#!/bin/bash

home_dir="/home/hippopotamus/GATK4_NGS/"
uniq_fnames=(`/bin/bash ./step0_get_fastq_CaseNames.sh`)


# step1 bwa mem alignment
for s in ${uniq_fnames[@]}; do
    printf "\nprocessing ${s}... \n\n"
    bwa mem \
        -K 100000000 \
        -Y \
        -M \
        -R "@RG\tID:${s}\tLB:${s}\tPL:ILLUMINA\tPM:HISEQ\tPU:unit1\tSM:${s}" \
        ${home_dir}reference/GRCh38_chr1.fa \
        ./1_FASTQ/${s}_CBW_chr1_R1.fastq.gz \
        ./1_FASTQ/${s}_CBW_chr1_R2.fastq.gz \
        > ./2_SAM_BAM/${s}_aligned_reads.sam
done


