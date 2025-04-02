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
