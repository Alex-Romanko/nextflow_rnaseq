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

// inputs:
params.fastq_dir = null
params.outdir = null
params.storeDir = "$projectDir"
params.multiqc = null

params.transcriptome_file = null
params.gtf_file = null

// for pre built CTAT lib usage
params.ctat_lib_dir = null

// options:
// if true - create local ctat built
// process will download source files
// and create CTAT lib loally
// takes several days
params.ctat_build = false
params.trim_x = true
params.rsem = true
params.UMI = false
params.val_get_dedup_stats = false


log.info """\
   A L E X * R N A S E Q * P I P E L I N E
   =======================================
   -------------------
   # profile         : ${workflow.profile}
   # project home    : ${workflow.projectDir}
   -------------------
   # transcriptome   : ${params.transcriptome_file}
   # gtf             : ${params.gtf_file}
   # CTAT_lib_dir    : ${params.ctat_lib_dir}
   -------------------
   # reads           : ${params.fastq_dir}
   # outdir          : ${params.outdir}
   # working dir     : ${workflow.workDir}
   # store dir       : ${params.storeDir}
   -------------------
   # UMI             : ${params.UMI}
   # RSEM expression : ${params.rsem}
   # CTAT_build      : ${params.ctat_build}
   -------------------
   =======================================
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
