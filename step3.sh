path="${HOME}/Pipeline1"

bowtie2 -q --local \
	-x "${path}/Tcongo_genome/Tcongo_genome" \
	-1 "${path}/fastq/"*_1*.fq \
	-2 "${path}/fastq/"*_2*.fq \
	2> "${path}/bowtie2_output/bowtie2_output.log" | \
samtools view -h -b -o "${path}/bowtie2_output/bowtie2_output.bam" -
