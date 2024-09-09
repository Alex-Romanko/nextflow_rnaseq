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
include { CTAT_LIB_BUILD } from '../modules/local/star_fusion/ctat_lib_build'



include { SEQKIT_PAIR_FQ } from '../modules/local/seqkit_pair'

include { FASTP as FASTP_TRIM_X } from '../modules/local/fastp'
include { FASTP as FASTP_TRIM_CLIP } from '../modules/local/fastp'


include { UMITOOLS_EXTRACT as UMI_EXTRACT } from '../modules/local/umi_extract'
include { UMITOOLS_DEDUP as UMI_DEDUP_GN } from '../modules/local/umi_dedup'
include { UMITOOLS_DEDUP as UMI_DEDUP_TR } from '../modules/local/umi_dedup'

include { PICARD_SORTSAM } from '../modules/local/picard/sortsam'



include { UMITOOLS_PREPAREFORRSEM } from '../modules/local/umi_prep_for_rsem'



include { SAMTOOLS_SORT as SAMTOOLS_SORT_TR } from '../modules/local/samtools_sort'

include { SAMTOOLS_INDEX } from '../modules/local/samtools_index'
include { SAMTOOLS_INDEX as SAMTOOLS_INDEX_TR } from '../modules/local/samtools_index'
include { SAMTOOLS_INDEX as SAMTOOLS_INDEX_DEDUP_TR } from '../modules/local/samtools_index'
include { RSEM_PREPAREREFERENCE } from '../modules/local/rsem_preparereference'
// include { SAMTOOLS_FAIDX } from '../modules/local/samtools_faidx'



include { RSEM_CALCULATEEXPRESSION } from '../modules/local/rsem_calculateexpression'

include { RSEM_MERGE_EXPRESSIONS } from '../modules/local/rsem_merge_expressions'
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

    // Channel
    // 	.fromFilePairs(params.fastq_dir + '/*R{1,2}*.fastq.gz', flat: true)
    // 	.map { prefix, file1, file2 -> tuple(getLibraryId(prefix), file1, file2) }
    // 	.groupTuple()
    // 	.set{ files_channel }

    Channel
	.fromFilePairs(params.fastq_dir + '/*R{1,2}*.fastq.gz', flat: true)
	.map { name, read1, read2 ->
	    (id) = name.tokenize("_")
	    meta = [id:id]
	    [meta, read1, read2]
	}
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


    if  ( params.trim_x ) {
	FASTP_TRIM_X ( merged_fq_ch )

	SEQKIT_PAIR_FQ( FASTP_TRIM_X.out.reads )
    } else {

	SEQKIT_PAIR_FQ( merged_fq_ch )
    }





    TRIMGALORE ( SEQKIT_PAIR_FQ.out.reads )

    TRIMGALORE
	.out
	.reads
	.set { read_pairs_ch }

    /*
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     if UMI
     then umi_star_wf
     else standart wf

     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     */


    if ( params.UMI ) {

	UMI_EXTRACT( read_pairs_ch )

	FASTP_TRIM_CLIP ( UMI_EXTRACT.out.reads )

	FASTQC( FASTP_TRIM_CLIP.out.reads )

	STAR_GENOMEGENERATE(genome_ch, gtf_ch )

	STAR_GENOMEGENERATE
	    .out
	    .genome_index
	    .first()
	    .set { star_ind_ch }

	STAR_ALIGN ( FASTP_TRIM_CLIP.out.reads, star_ind_ch )

	SAMTOOLS_INDEX ( STAR_ALIGN.out.bam_sorted )


	ch_star_bam = STAR_ALIGN.out.bam_sorted
	ch_bam_index = SAMTOOLS_INDEX.out.bai

	ch_get_umi_stats = Channel.value ( params.val_get_dedup_stats )
	UMI_DEDUP_GN ( ch_star_bam.join(ch_bam_index), ch_get_umi_stats )

	// PICARD_SORTSAM ( UMI_DEDUP_GN.out.bam )


	if ( params.rsem ) {

	    STAR_ALIGN
		.out
		.bam_transcript
		.set { transcript_bam_ch }




	    SAMTOOLS_SORT_TR ( transcript_bam_ch )

	    SAMTOOLS_INDEX_TR (SAMTOOLS_SORT_TR.out.bam )

	    UMI_DEDUP_TR ( SAMTOOLS_SORT_TR.out.bam.join(SAMTOOLS_INDEX_TR.out.bai), ch_get_umi_stats )
	    SAMTOOLS_INDEX_DEDUP_TR ( UMI_DEDUP_TR.out.bam )

	    UMITOOLS_PREPAREFORRSEM ( UMI_DEDUP_TR.out.bam.join(SAMTOOLS_INDEX_DEDUP_TR.out.bai) )

	    UMITOOLS_PREPAREFORRSEM
		.out
		.bam
		.set { transcript_bam_for_rsem_ch }

	}



    } else {


	FASTQC( read_pairs_ch )

	STAR_GENOMEGENERATE(genome_ch, gtf_ch )

	STAR_GENOMEGENERATE
	    .out
	    .genome_index
	    .first()
	    .set { star_ind_ch }

	STAR_ALIGN ( read_pairs_ch, star_ind_ch )

	SAMTOOLS_INDEX ( STAR_ALIGN.out.bam_sorted )

	if ( params.rsem ) {

	    STAR_ALIGN
		.out
		.bam_transcript
		.set { transcript_bam_for_rsem_ch }
	}

    }


    // end standart wf

    if ( params.rsem ) {

	RSEM_PREPAREREFERENCE ( genome_ch, gtf_ch, star_ind_ch )


	// rsem nput reference and stat transcriptome standart or dedup
	RSEM_CALCULATEEXPRESSION ( RSEM_PREPAREREFERENCE.out.index.first(), transcript_bam_for_rsem_ch )


	RSEM_CALCULATEEXPRESSION
	    .out
	    .counts_gene
	    .map{
		sapmle, file -> file
	    }
	    .collect(flat: true, sort: true)
	    .set{ genes_ch }

	RSEM_CALCULATEEXPRESSION
	    .out
	    .counts_transcript
	    .map{
		sapmle, file -> file
	    }
	    .collect(flat: true, sort: true)
	    .set{ isoforms_ch }

	RSEM_MERGE_EXPRESSIONS (genes_ch, isoforms_ch)
    }

    // ctat_source_ch = channel.fromPath( params.ctat_source, type: 'dir' )

    // CTAT_LIB_BUILD (genome_ch, gtf_ch)

    // SAMTOOLS_SORT ( RSEM_CALCULATEEXPRESSION.out.bam_transcript )

    // SAMTOOLS_INDEX_RSEM ( SAMTOOLS_SORT.out.bam )

    // TODO: add samtools index for transcriptome alignments
    // samtools NO_COOR reads not in a single block at the end

    // TODO: add multiqc
}



workflow.onComplete {
    log.info ( workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : "Oops .. something went wrong" )
}
