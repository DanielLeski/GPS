configfile: "configCamda.yaml"

#extract kmers
rule extract_kmers:
     input:
         k="data/camda/{sample}.fastq"
     params:
         kmer_size=config["kmer_size"]
     output:
          jf="data/kmer_counts/{sample}.jf"
     threads:
          4
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

rule log1p_count_feature:
     input:
        kmer_counts="data/data_filtered_fastq/{sample}.counts",
     params:
        n_features=config["n_features"]
     output:
        feature_matrix="data/log1p_features_count/{sample}.features"
     threads:
        4
     shell:
        "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.feature_matrix} --feature-scaling-before log1p --feature-scaling-after counts"

rule log1p_log1p_feature:
     input:
        kmer_counts="data/data_filtered_fastq/{sample}.counts",
     params:
        n_features=config["n_features"]
     output:
        feature_matrix="data/log1p_features_log1p/{sample}.features"
     threads:
        4
     shell:
        "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.feature_matrix} --feature-scaling-before log1p --feature-scaling-after log1p"

#Binarizer feature scaling combinations w/PCA
rule binarizer_binary_feature:
     input:
        kmer_counts="data/data_filtered_fastq/{sample}.counts",
     params:
        n_features=config["n_features"]
     output:
        feature_matrix="data/binarizer_features_binary/{sample}.features"
     threads:
        2
     shell:
        "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.feature_matrix} --feature-scaling-before binary --feature-scaling-after binary"

rule binarizer_count_feature:
     input:
        kmer_counts="data/data_filtered_fastq/{sample}.counts",
     params:
        n_features=config["n_features"]
     output:
        feature_matrix="data/binarizer_features_count/{sample}.features"
     threads:
        2
     shell:
        "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.feature_matrix} --feature-scaling-before binary --feature-scaling-after counts"

rule binarizer_log1p_feature:
     input:
        kmer_counts="data/data_filtered_fastq/{sample}.counts",
     params:
        n_features=config["n_features"]
     output:
        feature_matrix="data/binarizer_features_log1p/{sample}.features"
     threads:
        2
     shell:
        "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.feature_matrix} --feature-scaling-before binary --feature-scaling-after log1p"

#Counts feature combination w/PCA

rule counts_log1p_feature:
     input:
        kmer_counts="data/data_filtered_fastq/{sample}.counts",
     params:
        n_features=config["n_features"]
     output:
        feature_matrix="data/count_features_log1p/{sample}.features"
     threads:
        2
     shell:
        "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.feature_matrix} --feature-scaling-before counts --feature-scaling-after log1p"

rule counts_count_feature:
     input:
        kmer_counts="data/data_filtered_fastq/{sample}.counts",
     params:
        n_features=config["n_features"]
     output:
        feature_matrix="data/count_features_counts/{sample}.features"
     threads:
        2
     shell:
        "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.feature_matrix} --feature-scaling-before counts --feature-scaling-after counts"

rule counts_binary_feature:
     input:
        kmer_counts="data/data_filtered_fastq/{sample}.counts",
     params:
         n_features=config["n_features"]
     output:
        feature_matrix="data/count_features_binary/{sample}.features"
     threads:
        2
     shell:
        "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.feature_matrix} --feature-scaling-before counts --feature-scaling-after binary"

rule log1p_binary_feature:
     input:
        kmer_counts="data/data_filtered_fastq/{sample}.counts",
     params:
        n_features=config["n_features"]
     output:
        feature_matrix="data/log1p_features_binary/{sample}.features"
     threads:
        2
     shell:
        "scripts/feature_extractor.py --kmer-freq-fl {input.kmer_counts} --n-features {params.n_features} --feature-matrix {output.feature_matrix} --feature-scaling-before log1p --feature-scaling-after binary"

#PCA
rule pca_log1p_binary:
     input:
        feature_matrices=expand("data/log1p_features_binary/{sample}.features",
        sample=config["samples"])
     params:
        groups_fl=config["groups_fl"]
     output:
        plot="data/pca/pca_log1p_binary.png"
     threads:
        4
     shell:
        "scripts/pca.py --feature-matrices {input.feature_matrices} --groups-fl {params.groups_fl} --plot-fl {output.plot}"

rule pca_log1p_count:
     input:
        feature_matrices=expand("data/log1p_features_count/{sample}.features",
        sample=config["samples"])
     params:
        groups_fl=config["groups_fl"]
     output:
        plot="data/pca/pca_log1p_count.png"
     threads:
        4
     shell:
         "scripts/pca.py --feature-matrices {input.feature_matrices} --groups-fl {params.groups_fl} --plot-fl {output.plot}"

rule pca_log1p_log1p:
     input:
        feature_matrices=expand("data/log1p_features_log1p/{sample}.features",
        sample=config["samples"])
     params:
        groups_fl=config["groups_fl"]
     output:
        plot="data/pca/pca_log1p_log1p.png"
     threads:
        4
     shell:
        "scripts/pca.py --feature-matrices {input.feature_matrices} --groups-fl {params.groups_fl} --plot-fl {output.plot}"

rule pca_binarizer_binary:
     input:
        feature_matrices=expand("data/binarizer_features_binary/{sample}.features",
        sample=config["samples"])
     params:
        groups_fl=config["groups_fl"]
     output:
        plot="data/pca/pca_binary_binarizer.png"
     threads:
        4
     shell:
        "scripts/pca.py --feature-matrices {input.feature_matrices} --groups-fl {params.groups_fl} --plot-fl {output.plot}"


rule pca_binarizer_log1p:
     input:
        feature_matrices=expand("data/binarizer_features_log1p/{sample}.features",
        sample=config["samples"])
     params:
        groups_fl=config["groups_fl"]
     output:
        plot="data/pca/pca_binary_log1p.png"
     threads:
        4
     shell:
        "scripts/pca.py --feature-matrices {input.feature_matrices} --groups-fl {params.groups_fl} --plot-fl {output.plot}"

rule pca_binarizer_count:
     input:
        feature_matrices=expand("data/binarizer_features_count/{sample}.features", 
        sample=config["samples"])
     params:
        groups_fl=config["groups_fl"]
     output:
        plot="data/pca/pca_binary_count.png"
     threads:
        4
     shell:
        "scripts/pca.py --feature-matrices {input.feature_matrices} --groups-fl {params.groups_fl} --plot-fl {output.plot}"

rule pca_count_count:
     input:
        feature_matrices=expand("data/count_features_counts/{sample}.features",
        sample=config["samples"])
     params:
        groups_fl=config["groups_fl"]
     output:
        plot="data/pca/pca_count_count.png"
     threads:
        4
     shell:
        "scripts/pca.py --feature-matrices {input.feature_matrices} --groups-fl {params.groups_fl} --plot-fl {output.plot}"

rule pca_count_log1p:
     input:
        feature_matrices=expand("data/count_features_log1p/{sample}.features",
        sample=config["samples"])
     params:
        groups_fl=config["groups_fl"]
     output:
        plot="data/pca/pca_count_log1p.png"
     threads:
        4
     shell:
        "scripts/pca.py --feature-matrices {input.feature_matrices} --groups-fl {params.groups_fl} --plot-fl {output.plot}"

rule pca_count_binary:
     input:
        feature_matrices=expand("data/count_features_binary/{sample}.features",
        sample=config["samples"])
     params:
        groups_fl=config["groups_fl"]
     output:
        plot="data/pca/pca_count_binary.png"
     threads:
        4
     shell:
        "scripts/pca.py --feature-matrices {input.feature_matrices} --groups-fl {params.groups_fl} --plot-fl {output.plot}"

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
