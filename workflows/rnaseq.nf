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
include { SEQKIT_PAIR_FQ } from '../modules/local/seqkit_pair'
include { FASTP as FASTP_TRIM_X } from '../modules/local/fastp'
include { FASTP as FASTP_TRIM_CLIP } from '../modules/local/fastp'


include { UMITOOLS_EXTRACT as UMI_EXTRACT } from '../modules/local/umi_tools/umi_extract'
include { UMITOOLS_DEDUP as UMI_DEDUP_GN } from '../modules/local/umi_tools/umi_dedup'
include { UMITOOLS_DEDUP as UMI_DEDUP_TR } from '../modules/local/umi_tools/umi_dedup'
include { UMITOOLS_PREPAREFORRSEM } from '../modules/local/umi_tools/umi_prep_for_rsem'


include { PICARD_SORTSAM } from '../modules/local/picard/sortsam'

include { SAMTOOLS_SORT as SAMTOOLS_SORT_TR } from '../modules/local/samtools/samtools_sort'

include { SAMTOOLS_INDEX } from '../modules/local/samtools/samtools_index'
include { SAMTOOLS_INDEX as SAMTOOLS_INDEX_TR } from '../modules/local/samtools/samtools_index'
include { SAMTOOLS_INDEX as SAMTOOLS_INDEX_DEDUP_TR } from '../modules/local/samtools/samtools_index'
// include { SAMTOOLS_FAIDX } from '../modules/local/samtools/samtools_faidx'


include { STAR_GENOMEGENERATE } from '../modules/local/star/star_genome'
include { STAR_ALIGN } from '../modules/local/star/star_align'
include { CTAT_LIB_BUILD } from '../modules/local/star_fusion/ctat_lib_build'
include { STAR_FUSION_STAR } from '../modules/local/star_fusion/star_fusion_star'
include { STAR_FUSION_FIINSPECTOR } from '../modules/local/star_fusion/star_fusion_fiinspector'
include { STAR_FUSION_MERGE_TSV as MERGE_STAR_PREDICTIONS } from '../modules/local/star_fusion/merge_tsv'
include { STAR_FUSION_MERGE_TSV as MERGE_STAR_ABRIDGED } from '../modules/local/star_fusion/merge_tsv'
include { STAR_FUSION_MERGE_TSV as MERGE_STAR_CODING_EFF } from '../modules/local/star_fusion/merge_tsv'

include { RSEM_PREPAREREFERENCE } from '../modules/local/rsem/rsem_preparereference'
include { RSEM_CALCULATEEXPRESSION } from '../modules/local/rsem/rsem_calculateexpression'
include { RSEM_MERGE_EXPRESSIONS } from '../modules/local/rsem/rsem_merge_expressions'

include { ARRIBA_DOWNLOAD_DB } from '../modules/local/arriba/arriba_download_db'
include { ARRIBA_FUSION } from '../modules/local/arriba/arriba_fusion'
include { STAR_FUSION_MERGE_TSV as MERGE_ARRIBA_FUSIONS } from '../modules/local/star_fusion/merge_tsv'

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
	.first()
	.set{ genome_ch }

    Channel
	.fromPath( params.gtf_file, type: 'file' )
	.first()
	.set { gtf_ch }

    if ( params.ctat_build ) {

	CTAT_LIB_BUILD (genome_ch, gtf_ch)
	ch_ctat_lib = CTAT_LIB_BUILD.out.ctat_genome_lib.first()
    } else {
	Channel
	    .fromPath( params.ctat_lib_dir, type: 'any' ).first()
	    .set { ch_ctat_lib }
    }


    ARRIBA_DOWNLOAD_DB ()
    ARRIBA_DOWNLOAD_DB
	.out
	.arriba_db
	.set { arriba_db_ch }

    STAR_GENOMEGENERATE(genome_ch, gtf_ch )

    STAR_GENOMEGENERATE
	.out
	.genome_index
	.first()
	.set { star_ind_ch }





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

    // TRIMGALORE
    // 	.out
    // 	.reads
    // 	.set { read_pairs_ch }

    /*
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     if UMI
     then umi_star_wf
     else standart wf

     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     */


    if ( params.UMI ) {

	UMI_EXTRACT( TRIMGALORE.out.reads )

	FASTP_TRIM_CLIP ( UMI_EXTRACT.out.reads )

	FASTQC( FASTP_TRIM_CLIP.out.reads )


	ch_reads_for_star = FASTP_TRIM_CLIP.out.reads

	STAR_ALIGN ( ch_reads_for_star, star_ind_ch )
	SAMTOOLS_INDEX ( STAR_ALIGN.out.bam_sorted )

	ARRIBA_FUSION ( ch_reads_for_star, genome_ch, gtf_ch, star_ind_ch, arriba_db_ch)

	ch_merge_arriba_fn = channel.value( 'ALL.arriba.fusions' )
	ARRIBA_FUSION
	    .out
	    .fusions
	    .map{
		sapmle, file -> file
	    }
	    .collect(flat: true, sort: true)
	    .set{ arriba_out_fusions_ch }

	MERGE_ARRIBA_FUSIONS ( arriba_out_fusions_ch, ch_merge_arriba_fn )



	ch_star_bam = STAR_ALIGN.out.bam_sorted
	ch_bam_index = SAMTOOLS_INDEX.out.bai

	ch_get_umi_stats = Channel.value ( params.val_get_dedup_stats )
	// UMI_DEDUP_GN ( ch_star_bam.join(ch_bam_index), ch_get_umi_stats )

	// PICARD_SORTSAM ( UMI_DEDUP_GN.out.bam )


	if ( params.rsem ) {

	    STAR_ALIGN
		.out
		.bam_transcript
		.set { transcript_bam_for_rsem_ch }




	    // SAMTOOLS_SORT_TR ( transcript_bam_ch )

	    // SAMTOOLS_INDEX_TR (SAMTOOLS_SORT_TR.out.bam )

	    // UMI_DEDUP_TR ( SAMTOOLS_SORT_TR.out.bam.join(SAMTOOLS_INDEX_TR.out.bai), ch_get_umi_stats )
	    // SAMTOOLS_INDEX_DEDUP_TR ( UMI_DEDUP_TR.out.bam )

	    // UMITOOLS_PREPAREFORRSEM ( UMI_DEDUP_TR.out.bam.join(SAMTOOLS_INDEX_DEDUP_TR.out.bai) )

	    // UMITOOLS_PREPAREFORRSEM
	    // 	.out
	    // 	.bam
	    // 	.set { transcript_bam_for_rsem_ch }

	}



    } else {


	FASTQC( TRIMGALORE.out.reads )


	ch_reads_for_star = TRIMGALORE.out.reads

	STAR_ALIGN ( ch_reads_for_star, star_ind_ch )
	SAMTOOLS_INDEX ( STAR_ALIGN.out.bam_sorted )

	ARRIBA_FUSION ( ch_reads_for_star, genome_ch, gtf_ch, star_ind_ch, arriba_db_ch)

	ch_merge_arriba_fn = channel.value( 'ALL.arriba.fusions' )
	ARRIBA_FUSION
	    .out
	    .fusions
	    .map{
		sapmle, file -> file
	    }
	    .collect(flat: true, sort: true)
	    .set{ arriba_out_fusions_ch }

	MERGE_ARRIBA_FUSIONS ( arriba_out_fusions_ch, ch_merge_arriba_fn )


	if ( params.rsem ) {

	    STAR_ALIGN
		.out
		.bam_transcript
		.set { transcript_bam_for_rsem_ch }
	}

    }

    ch_star_fusion_reads_juntions = ch_reads_for_star.join(STAR_ALIGN.out.junction)
    STAR_FUSION_STAR (ch_star_fusion_reads_juntions, ch_ctat_lib)


    ch_fusions_fn = channel.value( 'ALL.starfusion.fusion_predictions' )
    STAR_FUSION_STAR
	.out
	.fusions
	.map{
	    sapmle, file -> file
	}
	.collect(flat: true, sort: true)
	.set{ fusions_star_ch }

    ch_fusions_abridged_fn = channel.value( 'ALL.starfusion.abridged' )
    STAR_FUSION_STAR
	.out
	.abridged
	.map{
	    sapmle, file -> file
	}
	.collect(flat: true, sort: true)
	.set{ abridged_star_ch }

    ch_fusions_coding_effect_fn = channel.value( 'ALL.starfusion.abridged.coding_effect' )
    STAR_FUSION_STAR
	.out
	.coding_effect
	.map{
	    sapmle, file -> file
	}
	.collect(flat: true, sort: true)
	.set{ coding_effect_star_ch }


    MERGE_STAR_PREDICTIONS ( fusions_star_ch, ch_fusions_fn )
    MERGE_STAR_ABRIDGED ( abridged_star_ch, ch_fusions_abridged_fn )
    MERGE_STAR_CODING_EFF ( coding_effect_star_ch, ch_fusions_coding_effect_fn )


    STAR_FUSION_FIINSPECTOR (ch_star_fusion_reads_juntions, ch_ctat_lib)

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


    // SAMTOOLS_SORT ( RSEM_CALCULATEEXPRESSION.out.bam_transcript )

    // SAMTOOLS_INDEX_RSEM ( SAMTOOLS_SORT.out.bam )

    // TODO: add samtools index for transcriptome alignments
    // samtools NO_COOR reads not in a single block at the end

    // TODO: add multiqc
}



workflow.onComplete {
    log.info ( workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : "Oops .. something went wrong" )
}
