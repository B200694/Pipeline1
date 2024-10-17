path="${HOME}/Pipeline1"

for file in "${path}/fastq/"*_1*.fq; do
	sample=$(basename "${file}" | awk -F '_' '{print $1}')
	read1="${path}/fastq/${sample}_1.fq"
	read2="${path}/fastq/${sample}_2.fq"
	echo -e "Aligning ${sample} to reference genome..."
	bowtie2 -q --local \
        -x "${path}/Tcongo_genome/Tcongo_genome" \
        -1 "${read1}" \
        -2 "${read2}" \
	2> "${path}/bowtie2_output/${sample}_bt2_output.log" | \
	samtools view -h -b -o "${path}/bowtie2_output/${sample}_bt2_output.bam" -
	echo -e "BAM file created for ${sample}"
done
