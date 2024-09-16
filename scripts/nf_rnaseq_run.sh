#! /usr/bin/env bash

set -euo pipefail

### add this script to your $PATH



showHelp() {

cat <<- EOF
This is a run script for nextflow_rna_seq pipeline

Running script without arguments results in execution default options
Check code bellow for currend defaults
You shold probably setup some of them for your environment

Also consider create a local version of the script and add some options to nextflow run
For example: -bg
             -with-report
             -c /path/to/local/user.config

Supported arguments:
-h    - print help massage and exit

-p    - sellect profile
      - currently avaleble profiles:
      'docker', 'singularity', 'slurm'
      - defaulf 'docker'

      - check nextflow.config for more information

-u    - Specific option for RNA RACE libraries
      'true' or 'false'

      - defaulf 'false'

Ussage example:
nf_rnaseq_run.sh -p 'slurm' -u 'true'

EOF

}

## pars optional parameters
## example:
## https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script
## https://stackoverflow.com/questions/30420354/bash-optional-argument-required-but-not-passed-for-use-in-getopts
while getopts hp:b:u: flag
do
    case "${flag}" in
        p)
	    profile=${OPTARG}
	    ;; # optional parametr for executor selection
	u)
	    umi=${OPTARG}
	    if ! [[ "$umi" = "true" || "$umi" = "false" ]]; then
		echo "Invalid value for UMI flag: ${umi}"
		echo "Accepted values: true/false."
		exit 1
	    fi
	   ;;
	b)
	    build_ctat=${OPTARG}
	    if ! [[ "$build_ctat" = "true" || "$build_ctat" = "false" ]]; then
		echo "Invalid value for Build CTAT Lib flag: ${build_ctat}"
		echo "Accepted values: true/false."
		exit 1
	    fi
	   ;;
	h)
	    showHelp
	    exit 0
	    ;;
	\?)
	    echo "$0: unknown option -$OPTARG" >&2;
	    showHelp
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
    CTAT_LIB_DIR="/home/alex/projects/DBs/trinity_ctat/GRCh38_gencode_v44_CTAT_lib_Oct292023.plug-n-play/ctat_genome_lib_build_dir"
    ## CTAT_SOURCE_DIR="/home/alex/projects/DBs/trinity_ctat/GRCh38_gencode_v44_CTAT_lib_Oct292023.source/"

    # Path to Nextflow script
    project_path="/home/alex/projects/nextflow_rna_seq/"
    SCRIPT="${SCRIPT:-${project_path}main.nf}"

    # Select profile
    PROFILE="docker" # set the default profile to docker if no arguments are present
    PROFILE="${profile:-$PROFILE}"

    MQC_CONF="MQC_CONF:-${project_path}/conf/multiqc_config.yaml"

    UMI="false"
    UMI="${umi:-$UMI}"
    # ctat_build
    BUILD_CTAT="false"
    BUILD_CTAT="${build_ctat:-$BUILD_CTAT}"



    ARGS=""
    ARGS="${nf_args:-$ARGS}"

    # Run Nextflow
    nextflow run "$SCRIPT" \
	     -work-dir "$WORKDIR" \
	     -profile "$PROFILE" \
	     -resume \
	     -ansi-log true \
	     --UMI "$UMI" \
	     --ctat_build "$BUILD_CTAT" \
	     --outdir "$RESULTS" \
	     --multiqc "$MULTIQC" \
	     --fastq_dir "$FASTQ" \
	     --transcriptome_file "$GENOME" \
	     --gtf_file "$GENOME_GTF" \
	     --ctat_lib_dir "$CTAT_LIB_DIR"
	     # --ctat_source "$CTAT_SOURCE_DIR"
}

run_nextflow
