path="${HOME}/Pipeline1"
conditions=("Clone1 0 Uninduced" "Clone2 0 Uninduced" "WT 0 Uninduced" \
	"Clone1 24 Uninduced" "Clone2 24 Uninduced" "WT 24 Uninduced" \
	"Clone1 48 Uninduced" "Clone2 48 Uninduced" "WT 48 Uninduced" \
	"Clone1 24 Induced" "Clone2 24 Induced" "WT 24 Induced" \
	"Clone1 48 Induced" "Clone2 48 Induced" "WT 48 Induced")

for condition in "${conditions[@]}"; do

	echo -e "Finding samples that match condition: ${condition}"

	IFS=" "
	read stype time treatment <<< ${condition}
	unset IFS

	outputfile="${path}/bedtools_output/${stype}_${time}_${treatment}_coverage.txt"
	
	echo -e "contig_id\tgene_start\tgene_end\ttranscript_id\tprotein\tread_count" \
        > "${outputfile}"

	samples=($(awk -F '\t' -v stype="${stype}" -v time="${time}" \
		-v treatment="${treatment}" \
		'$2 == stype && $4 == time && $5 == treatment {print $1}' Tco2.fqfiles))

	echo -e "Samples that match condition ${condition}: ${samples[@]}"
	echo -e "Merging ${samples[@]} into one bam file..."

	temp_bam="${path}/bowtie2_output/temp_combined.bam"
	bam_files=()

	for sample in "${samples[@]}"; do
		bam_files+=("${path}/bowtie2_output/${sample}_bt2_output.bam")
	done

	samtools merge -f "${temp_bam}" "${bam_files[@]}"

	echo -e "Merge complete"
	echo -e "Counting number of reads..."
	
	bedtools coverage -a "${path}/Tcongo_genome/TriTrypDB-46_TcongolenseIL3000_2019.bed" \
		-b "${temp_bam}" -counts >> "${outputfile}"

	echo -e "Calculated read counts for condition ${condition}"
done
