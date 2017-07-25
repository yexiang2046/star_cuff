#!/bin/bash
export WORK_DIR=~/RNAseqPipeLine/pipeline_star_cuff
cd ~/Data
mkdir ./bedGraph
while read filename;do
	$WORK_DIR/bin/STAR --runMode inputAlignmentsFromBAM \
	--outFileNamePrefix ./bedGraph/"$filename" \
	--inputBAMfile ~/Data/mapped_og/"$filename"Aligned.sortedByCoord.out.bam \
	--outWigType bedGraph --outWigStrand Stranded
done < sample_names.txt
