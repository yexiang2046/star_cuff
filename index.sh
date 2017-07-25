#!/bin/bash

while read filename; do
	samtools index ~/Data/mapped_og/"$filename"Aligned.sortedByCoord.out.bam
done < sample_names.txt
