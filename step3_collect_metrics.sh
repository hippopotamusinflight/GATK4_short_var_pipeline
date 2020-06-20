#!/bin/bash

home_dir="/home/hippopotamus/GATK4_NGS/"
uniq_fnames=(`/bin/bash ./step0_get_fastq_CaseNames.sh`)


# step3 collect metrics

for s in ${uniq_fnames[@]}; do
    printf "\nprocessing ${s}... \n\n"
    
    # collect alignment metrics
    java -jar $PICARD/picard.jar CollectAlignmentSummaryMetrics \
	R=${home_dir}reference/GRCh38_chr1.fa \
	I=./2_SAM_BAM/${s}_sorted_dedup_reads.bam \
	O=./0_METRICS/${s}_alignment_metrics.txt

    # collect insert size metrics
    java -jar $PICARD/picard.jar CollectInsertSizeMetrics \
	I=./2_SAM_BAM/${s}_sorted_dedup_reads.bam \
	O=./0_METRICS/${s}_insert_metrics.txt \
	HISTOGRAM_FILE=./0_METRICS/${s}_insert_size_histogram.pdf

    # read depth
    samtools depth -a \
	./2_SAM_BAM/${s}_sorted_dedup_reads.bam \
        > ./0_METRICS/${s}_depth_out.txt
done


