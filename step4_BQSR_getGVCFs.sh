#!/bin/bash

# must be inside gatk4 docker
# docker run --rm -v ~/GATK4_NGS:/gatk/GATK4_NGS -it broadinstitute/gatk

home_dir="/gatk/GATK4_NGS/"
uniq_fnames=(`/bin/bash ./step0_get_fastq_CaseNames.sh`)


for s in ${uniq_fnames[@]}; do
    
    printf "\nprocessing ${s}... \n\n"
    
    # step8 model BQSR #1
    gatk BaseRecalibrator \
        -R ${home_dir}/reference/GRCh38_chr1.fa \
        -I ./2_SAM_BAM/${s}_sorted_dedup_reads.bam \
        --known-sites ${home_dir}resources/Homo_sapiens_assembly38.dbsnp138.vcf \
        --known-sites ${home_dir}resources/Homo_sapiens_assembly38.known_indels.vcf.gz \
	 --known-sites ${home_dir}resources/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
        -O ./0_METRICS/${s}_recal_data.table

    # step9 apply BQSR #1
    gatk ApplyBQSR \
	 -R ${home_dir}/reference/GRCh38_chr1.fa \
	 -I ./2_SAM_BAM/${s}_sorted_dedup_reads.bam \
	 -bqsr ./0_METRICS/${s}_recal_data.table \
	 -O ./2_SAM_BAM/${s}_recal_reads.bam

    # step10 BQSR #2
    gatk BaseRecalibrator \
	 -R ${home_dir}/reference/GRCh38_chr1.fa \
	 -I ./2_SAM_BAM/${s}_recal_reads.bam \
	 --known-sites ${home_dir}resources/Homo_sapiens_assembly38.dbsnp138.vcf \
	 --known-sites ${home_dir}resources/Homo_sapiens_assembly38.known_indels.vcf.gz \
	 --known-sites ${home_dir}resources/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
	 -O ./0_METRICS/${s}_post_recal_data.table

    # step11 analyze covariates
    gatk AnalyzeCovariates \
	 -before ./0_METRICS/${s}_recal_data.table \
	 -after ./0_METRICS/${s}_post_recal_data.table \
	 -plots ./0_METRICS/${s}_recalibration_plots.pdf 

    # step12 call variants on BQSR recalibrated bam
    gatk HaplotypeCaller \
	 -R ${home_dir}/reference/GRCh38_chr1.fa \
	 -I ./2_SAM_BAM/${s}_recal_reads.bam \
	 -O ./3_GVCFs/${s}.g.vcf.gz \
	 -ERC GVCF

done


## EOF
