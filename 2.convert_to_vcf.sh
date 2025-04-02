#!/bin/bash
#
#SBATCH --job-name="chr_vcf"
#SBATCH -o chr1.o%j
#SBATCH -e chr1.e%j
#SBATCH --mail-user=m.chopra1@universityofgalway.ie
#SBATCH --mail-type=ALL
#SBATCH --partition="highmem","normal"

module load python3
python convert_to_vcf.py  
#python code to convert af to vcf files

##merging vcf-files

module load Anaconda3/2024.02-1
conda activate bcftools

bcftools merge chr*_200k_wgs.vcf.gz -Oz -o merged_1-22_200k_wgs.vcf.gz
tabix -p vcf merged_1-22_200k_wgs.vcf.gz

#vcf file contains "chr1" format. Removing chr using below
bcftools view merged_1-22_200k_wgs.vcf.gz | sed 's/^chr//g' > fixed_merged_1-22_200k_wgs.vcf
bgzip fixed_merged_1-22_200k_wgs.vcf
tabix -p vcf fixed_merged_1-22_200k_wgs.vcf

##focusing only targetted regions
bcftools view -R ../target_regions_yale_wes/xgen_plus_spikein.b38.bed fixed_merged_1-22_200k_wgs.vcf.gz > target_regions_ukb_200k.vcf

bgzip target_regions_ukb_200k.vcf
tabix -p vcf target_regions_ukb_200k.vcf.gz


