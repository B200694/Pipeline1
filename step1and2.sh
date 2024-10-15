### RUN FASTQC ###

path="${HOME}/Pipeline1"
inputfile=("$@")
html="${inputfile[-1]}"
unset 'inputfile[-1]'

# Remove old folders if present and create new output directory
# rm -rf ${path}/fastqc_output
# mkdir ${path}/fastqc_output  ## no permission??

# Check that the correct arguments are given
if [ ${#inputfile[@]} -eq 0 ] || { [ "$html" != "TRUE" ] && [ "$html" != "FALSE" ]; }; then
    echo "Please provide input files in the first argument and TRUE or FALSE in the second argument."
    echo "Enter TRUE to keep HTML files, or FALSE to remove."
    return 1
fi

# Show arguments
echo "There are ${#inputfile[@]} input files."
echo "Keep HTML: $html"

# Perform fastqc on all input files
for fq_file in ${inputfile[@]}; do
        fastqc "$fq_file" -o "${path}/fastqc_output" --noextract  # Run FastQC
done

# Remove HTML files based on user input
if [ "${html}" == "TRUE" ]; then
	echo "Keeping HTML files."
else 
	if [ "${html}" == "FALSE" ]; then
		echo "Removing HTML files"
		rm "${path}/fastqc_output/"*.html
	else
		echo -e "Second argument requires TRUE or FALSE input."
		echo -e "Enter TRUE to keep HTML files, or FALSE to remove"
		return 1
	fi
fi

if [ -f "${path}/fastqc_output/"*.html ]; then
	echo "HTML files kept."
else
	echo "HTML files removed."
fi

# extract zip files to the output directory
for filename in "${path}/fastqc_output/"*.zip
do
unzip $filename -d "${path}/fastqc_output/"
done

# remove the zip files as they are no longer needed
rm "${path}/fastqc_output/"*.zip
echo "Unzipped and removed .zip files."



### CREATE SUMMARY TABLE ###

# Create headings
echo -e   "sample\tread\tnum_seqs\tnum_poor_qual\tsequence_length\tper_N_seq_qual\t \
        per_seq_qual\toverrepresented" > summary_table.txt

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

	# Add the variable values to the summary table
	echo -e "${sample}\t${pair}\t${num_seqs}\t${num_poor_qual}\t \
                        ${sequence_length}\t${per_N_seq_qual}\t${per_seq_qual}\t \
                        ${overrepresented}" >> summary_table.txt
done

if [ -f "summary_table.txt" ]; then
        echo -e "Summary table created -> summary_table.txt"
else
        echo -e "Summary table could not be created"
fi
