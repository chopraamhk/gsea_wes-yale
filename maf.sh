#!/bin/bash
#
#SBATCH --job-name="merge_vcf"
#SBATCH -o m.o%j
#SBATCH -e m.e%j
#SBATCH --mail-user=m.chopra1@universityofgalway.ie
#SBATCH --mail-type=ALL
#SBATCH --partition="highmem","normal"
#code
module load Anaconda3/2024.02-1
conda activate bcftools

bcftools merge chr*_200k_wgs.vcf.gz -Oz -o merged_1-22_200k_wgs.vcf.gz
tabix -p vcf merged_1-22_200k_wgs.vcf.gz  # Index


bcftools view -i 'INFO/AF < 0.0001' merged_1-22_200k_wgs.vcf.gz -Oz -o merged_1-22_filtered_by_maf_200k_wgs.vcf.gz
