#!/bin/bash

raw_VCF_name="cohort_raw.vcf"

# must be inside gatk4 docker
# docker run --rm -v ~/GATK4_NGS:/gatk/GATK4_NGS -it broadinstitute/gatk

home_dir="/gatk/GATK4_NGS/"
uniq_fnames=(`/bin/bash ./step0_get_fastq_CaseNames.sh`)


# step15 data aggregation

printf "\nmerging\n"
printf "%s.g.vcf.gz \n" ${uniq_fnames[@]}
printf "\n"

GVCFs_args=()
for s in ${uniq_fnames[@]}; do
    GVCFs_args+=("-V./3_GVCFs/${s}.g.vcf.gz")
done

gatk GenomicsDBImport \
    "${GVCFs_args[@]}" \
    --genomicsdb-workspace-path ./cohort_db \
    --intervals chr1 \
    --merge-input-intervals true


# step16 joint genotyping

printf "\njoint genotyping\n"
printf "%s \n" ${uniq_fnames[@]}
printf "\n"

gatk GenotypeGVCFs \
    -R ${home_dir}/reference/GRCh38_chr1.fa \
    -V gendb://./cohort_db \
    -O ./4_RAW_VCF/${raw_VCF_name} 


## EOF
