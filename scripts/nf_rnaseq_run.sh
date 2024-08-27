#! /usr/bin/env bash

set -euo pipefail

### add this script to your $PATH


## pars optional parameters
## example:
## https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script
## https://stackoverflow.com/questions/30420354/bash-optional-argument-required-but-not-passed-for-use-in-getopts
while getopts p: flag
do
    case "${flag}" in
        p)
	    profile=${OPTARG}
	    ;; # optional parametr for executor selection

	\?)
	    echo "$0: unknown option -$OPTARG" >&2;
	    exit 1
	    ;; # fail if illegal option is presented
    esac
done


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

    # Select profile
    PROFILE="docker" # set the default profile to docker if no arguments are present
    PROFILE="${profile:-$PROFILE}"

    # Run Nextflow
    nextflow run "$SCRIPT" \
        -work-dir "$WORKDIR" \
	-profile "$PROFILE" \
        -resume \
	-ansi-log false \
        --outdir "$RESULTS" \
	--multiqc "$MULTIQC" \
	--fastq_dir "$FASTQ" \
	--transcriptome_file "$GENOME" \
	--gtf_file "$GENOME_GTF"

}

run_nextflow
