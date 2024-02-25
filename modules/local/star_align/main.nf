process STAR_ALIGN {
    maxForks 1
    tag "$sample_id"
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
    // def args = task.ext.args ?: ''
    // def sample_id = "${sample_id}"
    // def reads1 = reads[0], reads2 = reads[1]

    // sample_id.single_end ? [reads].flatten().each{reads1 << it} : reads.eachWithIndex{ v, ix -> ( ix & 1 ? reads2 : reads1) << v }
    // def ignore_gtf      = star_ignore_sjdbgtf ? '' : "--sjdbGTFfile $gtf"
    // def seq_platform    = seq_platform ? "'PL:$seq_platform'" : ""
    // def seq_center      = seq_center ? "'CN:$seq_center'" : ""
    // // def attrRG          = args.contains("--outSAMattrRGline") ? "" : "--outSAMattrRGline 'ID:$sample_id' $seq_center 'SM:$sample_id' $seq_platform"
    // def attrRG          =  "--outSAMattrRGline 'ID:$sample_id' 'SM:$sample_id' PL:ILLUMINA LB:lib1 PU:NNPIO "
    // def out_sam_type    = (args.contains('--outSAMtype')) ? '' : '--outSAMtype BAM Unsorted'
    // def mv_unsorted_bam = (args.contains('--outSAMtype BAM Unsorted SortedByCoordinate')) ? "mv ${sample_id}.Aligned.out.bam ${sample_id}.Aligned.unsort.out.bam" : ''
    """
    STAR \\
    --readFilesCommand zcat \\
    --genomeDir $index \\
    --readFilesIn ${reads[0]} ${reads[1]} \\
    --runThreadN 8 \\
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


    // if [ -f ${sample_id}.Unmapped.out.mate1 ]; then
    //     mv ${sample_id}.Unmapped.out.mate1 ${sample_id}.unmapped_1.fastq
    //     gzip ${sample_id}.unmapped_1.fastq
    // fi
    // if [ -f ${sample_id}.Unmapped.out.mate2 ]; then
    //     mv ${sample_id}.Unmapped.out.mate2 ${sample_id}.unmapped_2.fastq
    //     gzip ${sample_id}.unmapped_2.fastq
    // fi



    // STAR \
    // 	--runThreadN 8 \\
    // 	--genomeDir $index \\
    // 	--readFilesIn ${reads1.join(",")} ${reads2.join(",")} \\
    // 	--outFileNamePrefix results_star/"$i"_ \

    // 	--quantMode TranscriptomeSAM GeneCounts \\
    // 	--outSAMtype BAM SortedByCoordinate \\
    // 	--outSAMunmapped Within \\
    // 	--peOverlapNbasesMin 12 \
    // 	--peOverlapMMp 0.1  \
    // 	--genomeLoad NoSharedMemory \
    // 	--twopassMode Basic \
    // 	--outSAMattrRGline ID:"$i" SM:"$i" PL:ILLUMINA LB:lib1 PU:NNPIO \
    // 	--readFilesCommand 'bgzip -dc'
