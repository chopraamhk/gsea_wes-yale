#!/bin/bash
#
#SBATCH --job-name="split_vep"
#SBATCH -o split.o%j
#SBATCH -e split.e%j
#SBATCH --mail-user=m.chopra1@universityofgalway.ie
#SBATCH --mail-type=ALL
#SBATCH --partition="highmem","normal"

#code

module load Anaconda3/2024.02-1
conda activate bcftools
#here input is the annotated file from vep 
bgzip ukb_wgs_gnomad_annotated.vcf
tabix -p ukb_wgs_gnomad_annotated.vcf.gz

#removing variants if ac=0
bcftools view -e AC=0 ../ukb_wgs_gnomad_annotated.vcf.gz > ukb_wgs_target_ac0_gnomad.vcf
bgzip ukb_wgs_target_ac0_gnomad.vcf
tabix -p vcf ukb_wgs_target_ac0_gnomad.vcf.gz

#you can avoid following 4 lines of code and can start without getting worst or canonical transcripts
#splitting info fields so that we can extract by inputting info easily later
#bcftools +split-vep -p worst_ -a CSQ -c Allele,Consequence,IMPACT,SYMBOL,Gene,Feature_type,Feature,BIOTYPE,INTRON,HGVSc,HGVSp,cDNA_position,CDS_position,Protein_position,Amino_acids,Codons,Existing_variation,DISTANCE,STRAND,FLAGS,SYMBOL_SOURCE,HGNC_ID,CANONICAL,SOURCE,DOMAINS,LoFtool,gnomAD,gnomAD_AC,gnomAD_AN,gnomAD_AF -s worst ukb_wgs_target_ac0_gnomad.vcf.gz -o worst_output.vcf
#bcftools +split-vep -p canon_ -a CSQ -c Allele,Consequence,IMPACT,SYMBOL,Gene,Feature_type,Feature,BIOTYPE,INTRON,HGVSc,HGVSp,cDNA_position,CDS_position,Protein_position,Amino_acids,Codons,Existing_variation,DISTANCE,STRAND,FLAGS,SYMBOL_SOURCE,HGNC_ID,CANONICAL,SOURCE,DOMAINS,LoFtool,gnomAD,gnomAD_AC,gnomAD_AN,gnomAD_AF -s primary ukb_wgs_target_ac0_gnomad.vcf.gz -o canonical_output.vcf
#paste <(bcftools view worst_output.vcf) <(bcftools view canonical_output.vcf) > combined_worst_canonical_split_vep_results.vcf
#paste <(bcftools view worst_output.vcf) <(bcftools view canonical_output.vcf) > combined_worst_canonical_split_vep_results.tsv
##i was testing but -p worst_ -p canon_ can be given together in one command as well. that's recommendable.

#OR JUST DO BELOW 
bcftools +split-vep -a CSQ -c Allele,Consequence,IMPACT,SYMBOL,Gene,Feature_type,Feature,BIOTYPE,INTRON,HGVSc,HGVSp,cDNA_position,CDS_position,Protein_position,Amino_acids,Codons,Existing_variation,DISTANCE,STRAND,FLAGS,SYMBOL_SOURCE,HGNC_ID,CANONICAL,SOURCE,DOMAINS,LoFtool,gnomAD,gnomAD_AC,gnomAD_AN,gnomAD_AF -s primary ukb_wgs_target_ac0_gnomad.vcf.gz -o vep_split.vcf

bgzip vep_split.vcf
tabix -p vcf vep_split.vcf.gz

#removing variants if gnomad allele frequency is less than 0.0001. This might give an error because in info gnomAD_AF, type = string instead of float. this command expects to see number but is getting confused. 
#bcftools view -i 'INFO/gnomAD_AF<0.0001' vep_split.vcf.gz > ukb_wgs_gnomad_rare_filtered.vcf

#if you are seeing arithmatic opertaor error then 
bcftools view -i 'INFO/gnomAD_AF+0.0<0.0001' vep_split.vcf.gz > ukb_wgs_gnomad_rare_filtered.vcf
bgzip ukb_wgs_gnomad_rare_filtered.vcf
tabix -p vcf ukb_wgs_gnomad_rare_filtered.vcf.gz

or
bcftools view -i 'INFO/gnomAD_AF!="." && INFO/gnomAD_AF+0.0<0.0001 && INFO/gnomAD_AF+0.0>0' vep_split.vcf > ukb_wgs_gnomad_rare_filtered.vcf
#this can get rid of variants where gnomAD_AF is missing and gnomAD_AF is 0. 
 
##extracting rare variants
bcftools view -R genes_108_GRCh38.bed ukb_wgs_gnomad_rare_filtered.vcf.gz > genes_108_rare.vcf
bcftools view -R genes_27_GRCh38.bed ukb_wgs_gnomad_rare_filtered.vcf.gz > genes_27_rare.vcf
bcftools view -R utp11_vps8.bed ukb_wgs_gnomad_rare_filtered.vcf.gz > genes_utp11_vps8_rare.vcf

bgzip genes_108_rare.vcf
bgzip genes_27_rare.vcf
bgzip genes_utp11_vps8_rare.vcf

tabix -p vcf -f genes_108_rare.vcf.gz
tabix -p vcf -f genes_27_rare.vcf.gz
tabix -p vcf -f genes_utp11_vps8_rare.vcf.gz

##now, you can see which variants you would like to focus further. Can filter using #info as well.
#1) Likely-gene disrupting variants (LGD), 
#premature stop-gain
#frameshift indels
#canonical splicing variants
#cryptic splice site variants
#exon deletions 
#2) Deleterious missense variants (D-mis), 
#(defined as having a gMVP (in-silico predictor of pathogenicity) score of greater than 0.3, which is a minimal threshold for damaging variants.

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/gnomAD_AF\n' your_file.vcf | \
awk 'BEGIN { OFS="\t"; print "chr","pos","ref","alt","variant_type","gnomad_af" } 
{
    if(length($3)==1 && length($4)==1) vt="SNV";
    else if(length($3)<length($4)) vt="insertion";
    else if(length($3)>length($4)) vt="deletion";
    else vt="other";
    print $1, $2, $3, $4, vt, ($5=="" ? "." : $5);
}'
