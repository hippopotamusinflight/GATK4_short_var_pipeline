#!/bin/bash

home_dir="/gatk/GATK4_NGS/"


# step28 SnpEff

printf "\nSnpEff... \n\n"

java -Xmx4g -jar $SNPEFF/snpEff.jar eff \
     -c $SNPEFF/snpEff.config \
     GRCh38.86 \
     -v \
     -no-intergenic \
     -i vcf \
     -o vcf \
     -stats ./7_ANNOT/NA12878trio_snpEff_summary.html \
     ./7_ANNOT/NA12878trio_output_1000G_trio_PPs_GQ20filtered_dbSNPID_DP_deNovo.vcf.gz > \
     ./7_ANNOT/NA12878trio_output_1000G_trio_PPs_GQ20filtered_dbSNPID_DP_deNovo.ann.vcf.gz



# EOF
