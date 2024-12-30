#!/bin/sh 
#SBATCH --job-name="ao_genes"
#SBATCH -o ao_108.o%j
#SBATCH -e ao_108.e%j
#SBATCH --mail-user=mehak.chopra@yale.edu
#SBATCH --mail-type=ALL
#SBATCH --partition="ycga"

module load BCFtools/1.21-GCC-12.2.0

bcftools view -R 108_gene_regions.txt ../analysed_wes_vcf/TAA_1278EURpts_AC0_PCRO_VCF.vcf.gz -Oz -o variants_in_all.vcf.gz

bcftools view -i 'INFO/MAF<0.01' variants_in_all.vcf.gz -Oz -o maf_filtered.vcf.gz
bcftools index maf_filtered.vcf.gz

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/MAF\t%INFO/CSQ\n' maf_filtered.vcf.gz > variants_info.tsv

grep -v -E "synonymous_variant" variants_info.tsv > no_synonymous.tsv
##if want to exclude more then synonymous_variant | other_kind_of_variant 

awk '{print $1 "\t" $2}' no_synonymous.tsv > no_synonymous_regions.tsv

bcftools view -R no_synonymous_regions.tsv maf_filtered.vcf.gz -Oz -o rare_variants.vcf.gz
bcftools index rare_variants.vcf.gz

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/CSQ\n' rare_variants.vcf.gz | awk -F'|' '{print $4}' | sort | uniq -c > rare_vc.txt
~                               
