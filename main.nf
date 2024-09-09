#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Alex-Romanko/rnaseq
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github :
    Website:
    Slack  :
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

params.fastq_dir = null

// params.reads = "$projectDir/data/ns550_0104/race5/*R{1,2}*fastq.gz"
params.transcriptome_file = null
params.gtf_file = null

// pre built lib
params.ctat_lib_dir = null

// source for ctat lib creation
params.ctat_source = null

params.trim_x = true
params.rsem = true

params.multiqc = null
params.outdir = null
params.UMI = false
params.val_get_dedup_stats = false


log.info """\
    A L E X * R N A S E Q * P I P E L I N E
    =======================================
    transcriptome: ${params.transcriptome_file}
    gtf          : ${params.gtf_file}
    CTAT_LIB     : ${params.ctat_lib_dir}

    profile      : ${workflow.profile}
    project home : ${workflow.projectDir}
    working dir  : ${workflow.workDir}

    reads        : ${params.fastq_dir}
    outdir       : ${params.outdir}
    UMI          : ${params.UMI}
    multiqc      : ${params.multiqc}
    """
    .stripIndent(true)






/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include { RNASEQ } from './workflows/rnaseq'

//
// WORKFLOW: Run main rnaseq analysis pipeline
//
workflow MOL_RNASEQ {
    RNASEQ ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    MOL_RNASEQ ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
