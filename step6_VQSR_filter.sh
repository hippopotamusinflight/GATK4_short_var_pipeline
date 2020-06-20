#!/bin/bash

raw_VCF_name="cohort_raw.vcf"

# must be inside gatk4 docker
# docker run --rm -v ~/GATK4_NGS:/gatk/GATK4_NGS -it broadinstitute/gatk

home_dir="/gatk/GATK4_NGS/"
uniq_fnames=(`/bin/bash ./step0_get_fastq_CaseNames.sh`)


# step17 ExcessHet filtering
printf "\nExcessHet filtering %s\n\n" ${raw_VCF_name}

gatk --java-options "-Xmx3g -Xms3g" VariantFiltration \
     -V ./4_RAW_VCF/${raw_VCF_name} \
     --filter-expression "ExcessHet > 54.69" \
     --filter-name ExcessHet \
     -O ./5_FILT_VCF/cohort_excesshet.vcf.gz 


# step18 MakeSitesOnlyVcf
printf "\nMakeSitesOnlyVcf... \n\n"

gatk MakeSitesOnlyVcf \
     -I ./5_FILT_VCF/cohort_excesshet.vcf.gz \
     -O ./5_FILT_VCF/cohort_sitesonly.vcf.gz


# step19 VariantRecalibrator indels
printf "\nVariantRecalibrator indels... \n\n"

gatk --java-options "-Xmx24g -Xms24g" VariantRecalibrator \
     -V ./5_FILT_VCF/cohort_sitesonly.vcf.gz \
     --trust-all-polymorphic \
     -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
     -tranche 95.0 -tranche 94.0 -tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \
     -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an DP \
     -mode INDEL \
     --max-gaussians 2 \
     -resource:mills,known=false,training=true,truth=true,prior=12 ${home_dir}resources/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
     -resource:axiomPoly,known=false,training=true,truth=false,prior=10 ${home_dir}resources/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz \
     -resource:dbsnp,known=true,training=false,truth=false,prior=2 ${home_dir}resources/Homo_sapiens_assembly38.known_indels.vcf.gz \
     -O ./5_FILT_VCF/cohort_indels.recal \
     --tranches-file ./5_FILT_VCF/cohort_indels.tranches


# step20 VariantRecalibrator SNPs
printf "\nVariantRecalibrator SNPs... \n\n"

gatk --java-options "-Xmx3g -Xms3g" VariantRecalibrator \
    -V ./5_FILT_VCF/cohort_sitesonly.vcf.gz \
    --trust-all-polymorphic \
    -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.8 -tranche 99.6 -tranche 99.5 -tranche 99.4 \
    -tranche 99.3 -tranche 99.0 -tranche 98.0 -tranche 97.0 -tranche 90.0 \
    -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP \
    -mode SNP \
    --max-gaussians 6 \
    -resource:hapmap,known=false,training=true,truth=true,prior=15 ${home_dir}resources/hapmap_3.3.hg38.vcf.gz \
    -resource:omni,known=false,training=true,truth=true,prior=12 ${home_dir}resources/1000G_omni2.5.hg38.vcf.gz \
    -resource:1000G,known=false,training=true,truth=false,prior=10 ${home_dir}resources/1000G_phase1.snps.high_confidence.hg38.vcf.gz \
    -resource:dbsnp,known=true,training=false,truth=false,prior=7 ${home_dir}resources/Homo_sapiens_assembly38.dbsnp138.vcf \
    -O ./5_FILT_VCF/cohort_snps.recal \
    --tranches-file ./5_FILT_VCF/cohort_snps.tranches


# step21 ApplyVQSR indels
printf "\nApplyVQSR indels... \n\n"

gatk --java-options "-Xmx5g -Xms5g" ApplyVQSR \
     -V ./5_FILT_VCF/cohort_excesshet.vcf.gz \
     --recal-file ./5_FILT_VCF/cohort_indels.recal \
     --tranches-file ./5_FILT_VCF/cohort_indels.tranches \
     --truth-sensitivity-filter-level 99.7 \
     --create-output-variant-index true \
     -mode INDEL \
     -O ./5_FILT_VCF/indel.recalibrated.vcf.gz


# step22 ApplyVQSR SNPs
# change -V to ./5_FILT_VCF/indel.recalibrated.vcf.gz if indels have result

printf "\nApplyVQSR SNPs... \n\n"

gatk --java-options "-Xmx5g -Xms5g" ApplyVQSR \
    -V ./5_FILT_VCF/cohort_excesshet.vcf.gz \
    --recal-file ./5_FILT_VCF/cohort_snps.recal \
    --tranches-file ./5_FILT_VCF/cohort_snps.tranches \
    --truth-sensitivity-filter-level 99.7 \
    --create-output-variant-index true \
    -mode SNP \
    -O ./5_FILT_VCF/indel.snp.recalibrated.vcf.gz \


# step23 CollectVariantCallingMetrics
printf "\nCollectVariantCallingMetrics... \n\n"

gatk CollectVariantCallingMetrics \
    -I ./5_FILT_VCF/indel.snp.recalibrated.vcf.gz \
    --DBSNP ${home_dir}resources/Homo_sapiens_assembly38.dbsnp138.vcf \
    -SD ${home_dir}reference/Homo_sapiens_assembly38.dict \
    -O ./0_METRICS/postVQSR_metrics.txt


# EOF
