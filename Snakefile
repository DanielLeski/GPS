configfile: "/home/dan/fun/GPS/config.yaml"

rule filter_fastq:
     input:
         fastq="/home/dan/camda/{sample}",
     output:
         "data/filtered_fastq/{sample}.filtered.gz"
     threads:
         4
     shell:
        "fastqc {input.fastq}"  


#top-level rule
rule setup_inputs:
    input:
        filtered_fastq=expand("data/filtered_fastq/{sample}.filtered.gz", sample=config["samples"])







# Rule 0: Link the files like shown within the other pipeline 

# Rule 1: Opening and writing the files these fastq.gz files into a different directory
#  input: from config file
#  output: getting the files into a specific directory

## Don't forget to count the kmers from the files

#Rule 2: Filtering these files based on based counts that show up
#  input: getting the files from rule 1 
#  output: creating a directory where we store the filtered files

#Rule 3: sorting
#  input: kmers and the files fro mthe filtering files
#  output: sorted files with the occuranecs or kmers

#rules 4-N:
#  creating rules that run different strategies such as each classifer and technique and# etc
