#!/bin/bash

# must be inside gatk4 docker
# docker run --rm -v ~/GATK4_NGS:/gatk/GATK4_NGS -it broadinstitute/gatk

home_dir="/gatk/GATK4_NGS/"
uniq_fnames=(`/bin/bash ./step0_get_fastq_CaseNames.sh`)


# step2 mark duplicates and sort sam to bam
for s in ${uniq_fnames[@]}; do
    printf "\nprocessing ${s}... \n\n"
    
    gatk MarkDuplicatesSpark \
	-I ./2_SAM_BAM/${s}_aligned_reads.sam \
	-M ./0_METRICS/${s}_dedup_metrics.txt \
	-O ./2_SAM_BAM/${s}_sorted_dedup_reads.bam
    
done


