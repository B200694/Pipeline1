### CREATE SUMMARY TABLE ###
path="${HOME}/Pipeline1"

# Create headings
echo -e   "sample\tread\tnum_seqs\tnum_poor_qual\tsequence_length\tper_N_seq_qual\t \
        per_seq_qual\toverrepresented\tadapter_content" > summary_table.txt

# for each output file...
for dir in "${path}/fastqc_output/"*; do

        # Extract variables of interest
        sample=$(basename "${dir}" | awk -F'_' '{print $1}')
        pair=$(basename "${dir}" | awk -F'_' '{print $2}')
        num_seqs=$(awk -F'\t' 'NR==7 {print $2}' "${dir}/fastqc_data.txt")
        num_poor_qual=$(awk -F'\t' 'NR==8 {print $2}' "${dir}/fastqc_data.txt")
        sequence_length=$(awk -F'\t' 'NR==9 {print $2}' "${dir}/fastqc_data.txt")
        per_N_seq_qual=$(awk -F'\t' 'NR==2 {print $1}' "${dir}/summary.txt")
        per_seq_qual=$(awk -F'\t' 'NR==3 {print $1}' "${dir}/summary.txt")
        overrepresented=$(awk -F'\t' 'NR==9 {print $1}' "${dir}/summary.txt")
        adapter_content=$(awk -F'\t' 'NR==10 {print $1}' "${dir}/summary.txt")

        # Add the variable values to the summary table
        echo -e "${sample}\t${pair}\t${num_seqs}\t${num_poor_qual}\t \
                        ${sequence_length}\t${per_N_seq_qual}\t${per_seq_qual}\t \
                        ${overrepresented}\t${adapter_content}" >> summary_table.txt
done

if [ -f "summary_table.txt" ]; then
        echo -e "Summary table created -> summary_table.txt"
else
        echo -e "Summary table could not be created"
fi
