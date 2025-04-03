#!/bin/bash
#
#SBATCH --job-name="merge_vcf"
#SBATCH -o m.o%j
#SBATCH -e m.e%j
#SBATCH --mail-user=m.chopra1@universityofgalway.ie
#SBATCH --mail-type=ALL
#SBATCH --partition="highmem","normal"

module load Anaconda3/2024.02-1
conda activate bcftools

#to get the offtarget regions
bedtools intersect -v -a TAA_1278EURpts_AC0_VCF.vcf.gz -b target_regions_yale_wes/xgen_plus_spikein.b38.bed > off_target_TAA_1278_variants.vcf

#to get only the targetted regions 
bcftools view -R target_regions_yale_wes/xgen_plus_spikein.b38.bed target_regions_yale_wes/xgen_plus_spikein.b38.bed > target_TAA_1278EUR_200k.vcf
bgzip target_TAA_1278EUR_200k.vcf
tabix -p vcf target_TAA_1278EUR_200k.vcf

#if you want to know the number of variants in a specific vcf file 
#bcftools view -H file.vcf | wc -l

#-H -> it will get rid of the header
