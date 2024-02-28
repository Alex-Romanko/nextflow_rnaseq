/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Loaded from modules/local/
//
include { MERGE_FQ } from '../modules/local/merge_fasstq'
include { FASTQC } from '../modules/local/fastqc'
include { TRIMGALORE } from '../modules/local/trimgalore'
include { STAR_GENOMEGENERATE } from '../modules/local/star_genome'
include { STAR_ALIGN } from '../modules/local/star_align'

include { SAMTOOLS_SORT } from '../modules/local/samtools_sort'

include { SAMTOOLS_INDEX } from '../modules/local/samtools_index'
include { SAMTOOLS_INDEX as SAMTOOLS_INDEX_RSEM } from '../modules/local/samtools_index'
include { RSEM_PREPAREREFERENCE } from '../modules/local/rsem_preparereference'
// include { SAMTOOLS_FAIDX } from '../modules/local/samtools_faidx'



include { RSEM_CALCULATEEXPRESSION } from '../modules/local/rsem_calculateexpression'

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//

// include { PIPELINE_NAME } from '../subworkflows/local/pipeline_name'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//



//
// SUBWORKFLOW: Consisting entirely of nf-core/modules
//



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/



def getLibraryId( prefix ){
    // Return the ID number, you can change for other file formats, here it just takes the first part before "_"
    prefix.split("_")[0]
}

workflow RNASEQ {

    Channel
	.fromFilePairs(params.fastq_dir + '/*R{1,2}*.fastq.gz', flat: true)
	.map { prefix, file1, file2 -> tuple(getLibraryId(prefix), file1, file2) }
	.groupTuple()
	.set{ files_channel }

    Channel
	.fromPath( params.transcriptome_file, type: 'file' )
	.set{ genome_ch }

    Channel
	.fromPath( params.gtf_file, type: 'file' )
	.set { gtf_ch }

    MERGE_FQ ( files_channel )

    MERGE_FQ
	.out
	.reads
	.set { merged_fq_ch }

    TRIMGALORE ( merged_fq_ch )

    TRIMGALORE
	.out
	.reads
	.set { read_pairs_ch }

    FASTQC( read_pairs_ch )

    STAR_GENOMEGENERATE(genome_ch, gtf_ch )

    STAR_GENOMEGENERATE
	.out
	.genome_index
	.first()
	.set { star_ind_ch }

    RSEM_PREPAREREFERENCE ( genome_ch, gtf_ch, star_ind_ch )

    STAR_ALIGN ( read_pairs_ch, star_ind_ch )

    SAMTOOLS_INDEX ( STAR_ALIGN.out.bam_sorted )

    RSEM_CALCULATEEXPRESSION ( RSEM_PREPAREREFERENCE.out.index.first(), STAR_ALIGN.out.bam_transcript )

    SAMTOOLS_SORT ( RSEM_CALCULATEEXPRESSION.out.bam_transcript )

    SAMTOOLS_INDEX_RSEM ( SAMTOOLS_SORT.out.bam )

    // TODO: add samtools index for transcriptome alignments
    // samtools NO_COOR reads not in a single block at the end

    // TODO: add multiqc
}



workflow.onComplete {
    log.info ( workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : "Oops .. something went wrong" )
}
