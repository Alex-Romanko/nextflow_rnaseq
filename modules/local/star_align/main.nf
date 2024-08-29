process STAR_ALIGN {
    tag "STAR_ALIGN on $sample_id"
    // maxForks 1
    label 'process_high'
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(sample_id), path(reads)

    path index

    output:
    tuple val(sample_id), path('*Log.final.out')   , emit: log_final
    tuple val(sample_id), path('*Log.out')         , emit: log_out
    tuple val(sample_id), path('*Log.progress.out'), emit: log_progress

    tuple val(sample_id), path('*d.out.bam')              , optional:true, emit: bam
    tuple val(sample_id), path('*sortedByCoord.out.bam')  , optional:true, emit: bam_sorted
    tuple val(sample_id), path('*toTranscriptome.out.bam'), optional:true, emit: bam_transcript
    tuple val(sample_id), path('*Aligned.unsort.out.bam') , optional:true, emit: bam_unsorted
    tuple val(sample_id), path('*fastq.gz')               , optional:true, emit: fastq
    tuple val(sample_id), path('*.tab')                   , optional:true, emit: tab
    tuple val(sample_id), path('*.SJ.out.tab')            , optional:true, emit: spl_junc_tab
    tuple val(sample_id), path('*.ReadsPerGene.out.tab')  , optional:true, emit: read_per_gene_tab
    tuple val(sample_id), path('*.out.junction')          , optional:true, emit: junction
    tuple val(sample_id), path('*.out.sam')               , optional:true, emit: sam
    tuple val(sample_id), path('*.wig')                   , optional:true, emit: wig
    tuple val(sample_id), path('*.bg')                    , optional:true, emit: bedgraph


    script:

    """
    STAR \\
    --readFilesCommand zcat \\
    --genomeDir $index \\
    --readFilesIn ${reads[0]} ${reads[1]} \\
    --runThreadN $task.cpus \\
    --outFileNamePrefix $sample_id. \\
    --outSAMtype BAM SortedByCoordinate \\
    --quantMode TranscriptomeSAM GeneCounts \\
    --outSAMunmapped Within \\
    --peOverlapNbasesMin 12 \\
    --peOverlapMMp 0.1  \\
    --genomeLoad NoSharedMemory \\
    --twopassMode Basic \\
    --outSAMattrRGline 'ID:$sample_id' 'SM:$sample_id' PL:ILLUMINA LB:lib1 PU:NNPIO



    """

}
