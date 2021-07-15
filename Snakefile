configfile: "config.yaml"

#extract kmers
rule extract_kmers:
     input:
         k="data/camda/{sample}.fastq"
     params:
         kmer_size=config["kmer_size"]
     output:
          jf="data/kmer_counts/{sample}.jf"
     threads:
          6
     shell:
        # "jellyfish count -t {threads} -m {params.kmer_size} -s 1000M -C -o {output.jf} /dev/fd/0"
         "jellyfish count -t {threads} -m {params.kmer_size} -s 1000M -C -o {output.jf} {input.k}"

rule filter_fastq:
     input:
         k="data/kmer_counts/{sample}.jf"
     output:
         b="data/data_filtered_fastq/{sample}.counts"
     threads:
         4
     shell:
        "jellyfish dump -c -L 2 {input.k} > {output.b}"

rule sorting_kmers:
     input:
         count="data/kmer_counts/{sample}.counts"
     output:
          sorted_counts="data/kmer_counts_sorted/{sample}.sorted.counts"
     threads:
         6
     shell:
         "cut -f 1 -d \" \" {input.count} | sort -S 16G -parallel {threads} > {output.sorted_counts}"

rule extract_features:
     input:
         kmer_counts="data/data_filtered_fastq/{sample}.counts"
     params:
         n_features=config['n_features'],
         use_binary=config['use_binary_features']
     output:
         features="data/feature_extraction/{sample}.features"
     threads:
         2
     shell:
         "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.features}"

rule pca:
    input:
       feature_matrix=expand("data/feature_extraction/{sample}.features", sample=config['samples'])
    params:
       groups_fl=config['groups_fl']
    output:
       plot="data/pca/pca_plot.png"
    shell:
       "scripts/pca.py --feature-matrices {input.feature_matrix} --groups-fl {params.groups_fl} --plot-fl {output.plot}"

#rule dumping:
 #   input:
 #       kmer_counts=expand("data/kmer_counts/{sample}.counts", sample=config["samples"])

#rule counting:
#    input:
#       jf=expand("data/camda/{sample}.fastq", sample=config["samples"])


rule dumping:
    input:
        expand("data/data_filtered_fastq/{sample}.counts", sample=config["samples"])

rule counting:
    input:
        expand("data/kmer_counts/{sample}.jf", sample=config["samples"])

rule sort:
    input:
        expand("data/kmer_counts_sorted/{sample}.sorted.counts", sample=config["samples"])


#rules 4-N:
#  creating rules that run different strategies such as each classifer and technique and# etc
