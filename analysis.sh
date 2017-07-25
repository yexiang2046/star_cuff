#!/bin/bash
cd ~/Data

export WORK_DIR=~/RNAseqPipeLine/pipeline_star_cuff
export DATA=~/Data

if false;then
mkdir ./genome_index
$WORK_DIR/bin/STAR \
--runThreadN 100 \
--runMode genomeGenerate \
--genomeDir $DATA/genome_index \
--genomeFastaFiles $DATA/genome/GRCm38.p5.genome.fa \

#generate sample name list
echo "Generate sample name list..."
ls $DATA/OG |cut -d '_' -f 1,2 | sort -u > $DATA/sample_names.txt
fi

if false;then
#preprocessing data
echo "preprocessing..."
mkdir $DATA/preprocessed 
mkdir $DATA/preprocessed/paired
mkdir $DATA/preprocessed/unpaired
export preprocessed_paired=$DATA/preprocessed/paired
export preprocessed_unpaired=$DATA/preprocessed/unpaired
while read sample_name; do
	java -jar $WORK_DIR/bin/Trimmomatic-0.36/trimmomatic-0.36.jar PE -threads 16 -phred33 $DATA/OG/"$sample_name"_R1_001.fastq.gz $DATA/OG/"$sample_name"_R2_001.fastq.gz $preprocessed_paired/"$sample_name"_paired_R1.fastq.gz $preprocessed_unpaired/"$sample_name"_unpaired_R1.fastq.gz $preprocessed_paired/"$sample_name"_paired_R2_.fastq.gz $preprocessed_unpaired/"$sample_name"_unpaired_R2_fastq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
done < sample_names.txt
fi
# STAR alignment
if false;then
echo "Start maping"

#export preprocessed_paired=$DATA/preprocessed/paired
mkdir -p $DATA/mapped_og
while read sample_name; do
	$WORK_DIR/bin/STAR \
	--runThreadN 36 --genomeDir $DATA/genome_index \
	--sjdbGTFfile $DATA/annotation/gencode.vM14.chr_patch_hapl_scaff.annotation.gtf \
	--sjdbOverhang 100 \
	--outFileNamePrefix $DATA/mapped_og/"$sample_name" \
	--readFilesIn $DATA/OG/"$sample_name"_R1_001.fastq.gz \
	$DATA/OG/"$sample_name"_R2_001.fastq.gz \
	--readFilesCommand zcat \
	--outSAMtype BAM SortedByCoordinate
done < sample_names.txt
fi

#cufflinks
echo "cufflinking..."
while read filename; do
#	$WORK_DIR/bin/cufflinks -p 36 \
#	-o $DATA/clout/"$filename"_cl --library-type fr-firststrand \
#	$DATA/mapped_og/"$filename"Aligned.sortedByCoord.out.bam

	echo $DATA/clout/"$filename"_cl/transcripts.gtf >> $DATA/assemblies.txt
done < sample_names.txt
if false;then
#cuffmerge
echo "cuffmerge..."
$WORK_DIR/bin/cuffmerge -p 36 \
-g $DATA/annotation/gencode.vM14.chr_patch_hapl_scaff.annotation.gtf \
-s $DATA/genome/GRCm38.p5.genome.fa \
assemblies.txt
fi

#cuffdiff
echo "cuffdiff..."
$WORK_DIR/bin/cuffdiff -o diff_out \
-b $DATA/genome/GRCm38.p5.genome.fa -p 36 \
-L RD,HCD3d -u $DATA/merged_asm/merged.gtf \
-library-type fr-firststrand \
$DATA/mapped_og/402-XY-4_S12Aligned.sortedByCoord.out.bam,$DATA/mapped_og/402-XY-5_S13Aligned.sortedByCoord.out.bam,$DATA/mapped_og/402-XY-6_S14Aligned.sortedByCoord.out.bam,$DATA/mapped_og/402-XY-7_S15Aligned.sortedByCoord.out.bam \
$DATA/mapped_og/402-XY-1_S10Aligned.sortedByCoord.out.bam,$DATA/mapped_og/402-XY-2_S11Aligned.sortedByCoord.out.bam,$DATA/mapped_og/402-XY-8_S16Aligned.sortedByCoord.out.bam,$DATA/mapped_og/402-XY-10_S17Aligned.sortedByCoord.out.bam

