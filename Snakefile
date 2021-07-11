configfile: "config.yaml"

#extract kmers
rule extract_kmers:
     input:
         k="data/filtered_fastq/{sample}.fastq"
     params:
         kmer_size=config["kmer_size"]
     output:
          jf="data/kmer_counts/{sample}.jf"
     threads:
          3
     shell:
         "jellyfish count -t {threads} -m {params.kmer_size} -s 1000M -C -o {output.jf} {input.k}"

rule filter_fastq:
     input:
         k="data/kmer_counts/{sample}.jf"
     output:
         b="data/data_filtered_fastq/{sample}.counts"
     threads:
         6
     shell:
        "jellyfish dump -c -L 2 {input.k} > {output.b}"


rule dumping:
    input:
        expand("data/data_filtered_fastq/{sample}.counts", sample=config["samples"])

rule counting:
    input:
        expand("data/kmer_counts/{sample}.jf", sample=config["samples"])



#rules 4-N:
#  creating rules that run different strategies such as each classifer and technique and# etc
