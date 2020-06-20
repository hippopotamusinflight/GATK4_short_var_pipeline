#!bin/ash

fname_arr=(./1_FASTQ/*.fastq.gz)
sample_names=()

for file in "${fname_arr[@]}"; do
    fnameWOpath="${file##*/}"
    fname_final=`expr "${fnameWOpath}" : '\(NA.*[0-9][0-9]\)'`
    # filenameWithoutExtension="${filename%.*}"
    sample_names+=(${fname_final})
done

uniq_fnames=($(echo "${sample_names[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

echo ${uniq_fnames[@]}
