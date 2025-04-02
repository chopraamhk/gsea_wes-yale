input_file = "../ukb24304_c22_v1.af"  # Compressed input file
output_file = "chr22_200k_wgs.vcf"

# VCF Header
vcf_header = """##fileformat=VCFv4.2
##INFO=<ID=AF,Number=A,Type=Float,Description="Allele Frequency">
#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO
"""

# Open gzipped input and normal output file
with open(input_file, "rt") as infile, open(output_file, "w") as outfile:
    outfile.write(vcf_header)

    for line in infile:
        parts = line.strip().split()
        chrom = parts[0]
        pos = parts[1]
        ref = parts[2]
        alts = parts[3]
        afs = parts[4]

        # Handle multiple alternate alleles
        alt_list = alts.split(",")
        af_list = afs.split(",")

        # Format INFO field with AF
        info_field = f"AF={','.join(af_list)}"

        # Write VCF line
        vcf_line = f"{chrom}\t{pos}\t.\t{ref}\t{','.join(alt_list)}\t.\t.\t{info_field}\n"
        outfile.write(vcf_line)

print(f"VCF file saved as {output_file}")
