#!/bin/bash

# must be inside gatk4 docker
# docker run --rm -v ~/GATK4_NGS:/gatk/GATK4_NGS -it broadinstitute/gatk

home_dir="/gatk/GATK4_NGS/"


# step24 CalculateGenotypePosteriors 
# with supporting + family priors (no input sample priors since < 10 samples)
printf "\nCalculateGenotypePosteriors... \n\n"

gatk --java-options "-Xmx4g" CalculateGenotypePosteriors \
     -V ./5_FILT_VCF/indel.snp.recalibrated.vcf.gz \
     -O ./6_REFINE_GT/NA12878trio_output_1000G_trio_PPs.vcf.gz \
     -ped ${home_dir}data/NA12878trio.ped \
     -supporting ${home_dir}resources/1000G.phase3.integrated.sites_only.no_MATCHED_REV.hg38.vcf


# step25 VariantFiltration 
printf "\nVariantFiltration... \n\n"

gatk VariantFiltration \
     -R ${home_dir}reference/GRCh38_chr1.fa \
     -V ./6_REFINE_GT/NA12878trio_output_1000G_trio_PPs.vcf.gz \
     -O ./6_REFINE_GT/NA12878trio_output_1000G_trio_PPs_GQ20filtered.vcf.gz \
     -filter "GQ<20" -filter-name "lowGQ"



# EOF
