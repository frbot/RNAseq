#! /bin/sh
echo "RNAseq-analysis-and-feature-count.sh input prefix fastq1 fastq2 gff"

# Read input file

#echo "Enter the input reference filename:"
input="$1"

#echo "Enter the output prefix"
prefix="$2"

#echo "Enter the fastq file 1"
fastq1="$3"

#echo "Enter the fastq file 2"
fastq2="$4"

#echo "Enter the gff file"
gff="$5"


# Bowtie2 alignment
bowtie2-build $input $prefix ;
bowtie2 -x $prefix -1 $fastq1 -2 $fastq2 -S $prefix.sam ;

#convert sam to bam
samtools view -Sb $prefix.sam -o $prefix.bam ;

#sort the bam file
samtools sort $prefix.bam -o "$prefix"-sorted.bam ;

#index the bam file
samtools index "$prefix"-sorted.bam ;

#compute consensus
#samtools mpileup -uf $input "$prefix"-sorted.bam | bcftools view -cg - | vcfutils.pl vcf2fq > "$prefix"-consensus.fq

#convert fastq to fasta
#convert_project -f fastq -t fasta "$prefix"-consensus.fq "$prefix"-consensus

#Obtain statistics
samtools depth $prefix-sorted.bam |  awk '{sum+=$3} END { print "Average = ",sum/NR}' > $prefix-mapping_coverage ;
var=$(samtools view -c -F 260 $prefix-sorted.bam); echo "Number of mapped reads = $var" >> $prefix-mapping_coverage ;


#Fetures counts from GFF file

htseq-count -t gene -i ID -s no -q $prefix.sam $gff > $prefix.counts ;
sed -i "1iLocus\t${prefix}" $prefix.counts ;

echo "Computation finished :)"

exit 0
