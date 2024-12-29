# gsea_wes-yale

1. Mapped snps to genes (to a distance of 500kb). Start with a gene list, start and end region of the gene.

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
bcftools view -i 'INFO/MAF<0.01' variants_in_all.vcf.gz -o maf_filtered.vcf
```

4. As we are going to focus on just rare-variants, exclude synonymous variants but first make a table where all the annotated variant info with MAF will be there. 
```
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/MAF\t%INFO/CSQ\n' maf_filtered.vcf > variants_info.tsv
```

5. You can remove the synonymous mutations by filtering tsv file (using awk) or below command
```
bcftools view -e 'INFO/ANN[0] ~ "synonymous_variant"' maf_filtered.vcf -o no_synonymous.vcf
``` 

6. Now, time to count the variants in per gene
```
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/CSQ\n' no_synonymous.vcf | awk -F'|' '{print $4}' | sort | uniq -c > variant_counts.txt
```




