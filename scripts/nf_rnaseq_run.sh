#! /usr/bin/env bash

set -euo pipefail

### add this script to your $PATH

function run_nextflow {
    # PATH to fastq
    FASTQ="${PWD}/"

    # Nextflow work directory
    WORKDIR="${PWD}/work"

    # PATH where to store results from Nextflow
    RESULTS="${PWD}/results"
    MULTIQC="${RESULTS}/multiqc"

    ### SET VALUES ###
    # PATH to genome
    GENOME="/home/alex/projects/DBs/GenCode/GRCh38.p14.genome.fa"
    GENOME_GTF="/home/alex/projects/DBs/GenCode/gencode.v44.annotation.gtf"

    # Path to Nextflow script
    SCRIPT="${SCRIPT:-/home/alex/projects/nextflow_rna_seq/main.nf}"

    # Run Nextflow
    nextflow run "$SCRIPT" \
        -work-dir "$WORKDIR" \
        -resume \
        --outdir "$RESULTS" \
	--multiqc "$MULTIQC" \
	--fastq_dir "$FASTQ" \
	--transcriptome_file "$GENOME" \
	--gtf_file "$GENOME_GTF"

}

run_nextflow
