process STAR_ALIGN {
    tag "STAR_ALIGN on $meta.id"
    // maxForks 1
    label 'process_high'
    publishDir params.outdir, mode:'copy'
    scratch '$TMPDIR'
    stageOutMode 'move'

    input:
    tuple val(meta), path(reads)

    path index

    output:
    tuple val(meta), path('*Log.final.out')   , emit: log_final
    tuple val(meta), path('*Log.out')         , emit: log_out
    tuple val(meta), path('*Log.progress.out'), emit: log_progress

    tuple val(meta), path('*d.out.bam')              , optional:true, emit: bam
    tuple val(meta), path('*sortedByCoord.out.bam')  , optional:true, emit: bam_sorted
    tuple val(meta), path('*toTranscriptome.out.bam'), optional:true, emit: bam_transcript
    tuple val(meta), path('*Aligned.unsort.out.bam') , optional:true, emit: bam_unsorted
    tuple val(meta), path('*fastq.gz')               , optional:true, emit: fastq
    tuple val(meta), path('*.tab')                   , optional:true, emit: tab
    tuple val(meta), path('*.SJ.out.tab')            , optional:true, emit: spl_junc_tab
    tuple val(meta), path('*.ReadsPerGene.out.tab')  , optional:true, emit: read_per_gene_tab
    tuple val(meta), path('*.out.junction')          , optional:true, emit: junction
    tuple val(meta), path('*.out.sam')               , optional:true, emit: sam
    tuple val(meta), path('*.wig')                   , optional:true, emit: wig
    tuple val(meta), path('*.bg')                    , optional:true, emit: bedgraph


    script:
    def args = task.ext.args ?: ''

    """
    STAR \\
    --readFilesCommand zcat \\
    --genomeDir $index \\
    --readFilesIn ${reads[0]} ${reads[1]} \\
    --outReadsUnmapped None \\
    --runThreadN $task.cpus \\
    --outFileNamePrefix ${meta.id}. \\
    --outSAMtype BAM SortedByCoordinate \\
    --quantMode TranscriptomeSAM GeneCounts \\
    --outSAMunmapped Within \\
    --outSAMstrandField intronMotif \\
    --peOverlapNbasesMin 12 \\
    --peOverlapMMp 0.1  \\
    --genomeLoad NoSharedMemory \\
    --twopassMode Basic \\
    --outSAMattrRGline 'ID:${meta.id}' 'SM:${meta.id}' PL:ILLUMINA LB:lib1 PU:NNPIO \\
    --chimOutJunctionFormat 1 \\
    --chimSegmentMin 12 \\
    --chimJunctionOverhangMin 8 \\
    --alignSJDBoverhangMin 10 \\
    --alignMatesGapMax 1000000 \\
    --alignIntronMax 1000000 \\
    --alignSJstitchMismatchNmax 5 -1 5 5 \\
    --chimMultimapScoreRange 3 \\
    --chimScoreJunctionNonGTAG -4 \\
    --chimMultimapNmax 20 \\
    --chimNonchimScoreDropMin 10 \\
    --alignInsertionFlush Right \\
    --alignSplicedMateMapLminOverLmate 0 \\
    --alignSplicedMateMapLmin 30 \\
    $args
    """


// ###
// # My first try based on nf-core
// STAR \\
// --readFilesCommand zcat \\
// --genomeDir $index \\
// --readFilesIn ${reads[0]} ${reads[1]} \\
// --runThreadN $task.cpus \\
// --outFileNamePrefix ${meta.id}. \\
// --outSAMtype BAM SortedByCoordinate \\
// --quantMode TranscriptomeSAM GeneCounts \\
// --outSAMunmapped Within \\
// --peOverlapNbasesMin 12 \\
// --peOverlapMMp 0.1  \\
// --genomeLoad NoSharedMemory \\
// --twopassMode Basic \\
// --outSAMattrRGline 'ID:${meta.id}' 'SM:${meta.id}' PL:ILLUMINA LB:lib1 PU:NNPIO


// // NM flags:
// // --sjdbOverhang 150 --clip5pNbases 2,2 --clip3pNbases 10,0 --peOverlapNbasesMin 5

// // star - fusion suggestions:

// ###
// # Parameters that we recommend for running STAR (as of STAR-v2.7.2a) as part of STAR-Fusion are as follows:
// STAR --genomeDir ${star_index_dir} \
//           --readFilesIn ${left_fq_filename} ${right_fq_filename} \
//           --outReadsUnmapped None \
//           --twopassMode Basic \
//           --readFilesCommand "gunzip -c" \
//           --outSAMstrandField intronMotif \  # include for potential use with StringTie for assembly
//           --outSAMunmapped Within
// ###
// # and including the following parameters that are relevant to fusion detection and STAR-Fusion execution:
//        --chimSegmentMin 12 \  # ** essential to invoke chimeric read detection & reporting **
//        --chimJunctionOverhangMin 8 \
//        --chimOutJunctionFormat 1 \   # **essential** includes required metadata in Chimeric.junction.out file.
//        --alignSJDBoverhangMin 10 \
//        --alignMatesGapMax 100000 \   # avoid readthru fusions within 100k
//        --alignIntronMax 100000 \
//        --alignSJstitchMismatchNmax 5 -1 5 5 \   # settings improved certain chimera detections
//        --outSAMattrRGline ID:GRPundef \
//        --chimMultimapScoreRange 3 \
//        --chimScoreJunctionNonGTAG -4 \
//        --chimMultimapNmax 20 \
//        --chimNonchimScoreDropMin 10 \
//        --peOverlapNbasesMin 12 \
//        --peOverlapMMp 0.1 \
//        --alignInsertionFlush Right \
//        --alignSplicedMateMapLminOverLmate 0 \
//        --alignSplicedMateMapLmin 30
// ###
// # This will (in part) generate a file called 'Chimeric.out.junction', which is used by STAR-Fusion like so:
// # Basic
// STAR-Fusion --genome_lib_dir /path/to/your/CTAT_resource_lib \
//              -J Chimeric.out.junction \
//              --output_dir star_fusion_outdir

// # Fiinspector + Trinity
// # and now running STAR-Fusion & FusionInspector 'inspect' & Trinity de-novo reconstruction via Docker,
// # below we assume you have your reads_1.fq.gz and reads_2.fq.gz in your current working directory
// # and also have the ctat_genome_lib_build_dir in your current directory.

// docker run -v `pwd`:/data --rm trinityctat/starfusion \
//     STAR-Fusion \
//     --left_fq /data/reads_1.fq.gz \
//     --right_fq /data/reads_2.fq.gz \
//     --genome_lib_dir /data/ctat_genome_lib_build_dir \
//     -O /data/StarFusionOut \
//     --FusionInspector validate \
//     --examine_coding_effect \
//     --denovo_reconstruct

// // # STAR-fusion-NF
// 	STAR --runMode alignReads \
//     	--genomeDir \$PWD/$genome_lib/ref_genome.fa.star.idx \
// 		--runThreadN 8 \
// 		--readFilesIn $R1 $R2 \
// 		--outFileNamePrefix $Sample \
// 		--outReadsUnmapped None \
// 		--twopassMode Basic \
// 		--twopass1readsN -1 \
// 		--readFilesCommand "gunzip -c" \
// 		--outSAMunmapped Within \
// 		--outSAMtype BAM SortedByCoordinate \
// 		--limitBAMsortRAM 63004036730 \
// 		--outSAMattributes NH HI NM MD AS nM jM jI XS \
// 		--chimSegmentMin 12 \
// 		--chimJunctionOverhangMin 12 \
// 		--chimOutJunctionFormat 1 \
// 		--alignSJDBoverhangMin 10 \
// 		--alignMatesGapMax 100000 \
// 		--alignIntronMax 100000 \
// 		--alignSJstitchMismatchNmax 5 -1 5 5 \
// 		--outSAMattrRGline ID:GRPundef \
// 		--chimMultimapScoreRange 3 \
// 		--chimScoreJunctionNonGTAG -4 \
// 		--chimMultimapNmax 20 \
// 		--chimNonchimScoreDropMin 10 \
// 		--peOverlapNbasesMin 12 \
// 		--peOverlapMMp 0.1 \
// 		--chimFilter banGenomicN

// 	STAR-Fusion --genome_lib_dir \$PWD/$genome_lib \
// 	  	--chimeric_junction "${Sample}Chimeric.out.junction" \
// 		--left_fq $R1 \
// 		--right_fq $R2 \
// 	  	--CPU 8 \
// 	  	--FusionInspector inspect \
// 	  	--examine_coding_effect \
// 	  	--denovo_reconstruct \
// 	  	--output_dir $Sample



}
