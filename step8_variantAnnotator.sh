#!/bin/bash

# must be inside gatk4 docker
# docker run --rm -v ~/GATK4_NGS:/gatk/GATK4_NGS -it broadinstitute/gatk

home_dir="/gatk/GATK4_NGS/"
uniq_fnames=(`/bin/bash ./step0_get_fastq_CaseNames.sh`)

# step26 VariantAnnotator dbSNP ID and coverage

printf "\nVariantAnnotator dbSNP ID and coverage... \n\n"

bam_args=()
for s in ${uniq_fnames[@]}; do
    bam_args+=("-I./2_SAM_BAM/${s}_recal_reads.bam")
done

gatk VariantAnnotator \
     -R ${home_dir}/reference/GRCh38_chr1.fa \
     "${bam_args[@]}" \
     -V ./6_REFINE_GT/NA12878trio_output_1000G_trio_PPs_GQ20filtered.vcf.gz \
     -O ./7_ANNOT/NA12878trio_output_1000G_trio_PPs_GQ20filtered_dbSNPID_DP.vcf.gz \
     -A Coverage \
     --dbsnp ${home_dir}resources/Homo_sapiens_assembly38.dbsnp138.vcf


# step27 VariantAnnotator PossibleDeNovo
printf "\nVariantAnnotator PossibleDeNovo... \n\n"

gatk VariantAnnotator \
     -R ${home_dir}/reference/GRCh38_chr1.fa \
     -V ./7_ANNOT/NA12878trio_output_1000G_trio_PPs_GQ20filtered_dbSNPID_DP.vcf.gz \
     -A PossibleDeNovo \
     -ped ${home_dir}data/NA12878trio.ped \
     -O ./7_ANNOT/NA12878trio_output_1000G_trio_PPs_GQ20filtered_dbSNPID_DP_deNovo.vcf.gz \


# EOF
