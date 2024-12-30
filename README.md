# gsea_wes-yale

1. Mapped SNPs to genes (to a distance of 500kb). Start with a gene list and start and end region of the gene.

Gene list (gene_list.txt) should look like below but without headers (tab-delimited file)
```
chr  start_region  end_region
1  27654  27700
```

2. Extract all the variants falling in that region. This will give you all variants in that gene.
```
bcftools view -R gene_list.txt all.vcf.gz -o variants_in_all.vcf.gz
```
  
3. Focus on variants with MAF <0.01 (i.e., 1%).
```
bcftools view -i 'INFO/MAF<0.01' variants_in_all.vcf.gz -o maf_filtered.vcf.gz
```

4. As we will focus on rare variants, exclude synonymous variants. First, make a table with all the annotated variant info with MAF.
```
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/MAF\t%INFO/CSQ\n' maf_filtered.vcf.gz > variants_info.tsv
```

5. You can remove the synonymous mutations by filtering the .tsv file (using awk) or the below command
```
grep -v -E "synonymous_variant" variants_info.tsv > no_synonymous.tsv
```
##can add more like "synonymous_variant | other_kind_variant" 

6. Get chromosome ID and position for those rare variants
```
awk '{print $1 "\t" $2}' no_synonymous.tsv > no_synonymous_regions.tsv
```

7. Extract the variants from above vcf file
```
bcftools view -R no_synonymous_regions.tsv maf_filtered.vcf.gz > rare_variants.vcf
```

8. Now, it is time to count the variants per gene
```
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/CSQ\n' rare_variants.vcf | awk -F'|' '{print $4}' | sort | uniq -c > rare_vc.txt
```

7. Time to do hypergeometric tests or GSEA analysis
https://yulab-smu.top/biomedical-knowledge-mining-book/enrichment-overview.html
https://montilab.github.io/BS831/articles/docs/HyperEnrichment.html


might be worth checking: https://github.com/mhguo1/TRAPD
