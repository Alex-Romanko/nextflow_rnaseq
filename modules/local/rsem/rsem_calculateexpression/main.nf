process RSEM_CALCULATEEXPRESSION {
    label 'process_high'
    tag "RSEM_expr on $meta.id"
    publishDir params.outdir + "/rsem_expressions", mode:'copy'

    // label 'process_high'

    input:
    // tuple val(meta), path(reads)
    path index
    tuple val (meta), path(bam)

    output:
    tuple val(meta), path("*.genes.results")   , emit: counts_gene
    tuple val(meta), path("*.isoforms.results"), emit: counts_transcript
    tuple val(meta), path("*.stat")            , emit: stat
    // tuple val(meta), path("*.log")             , emit: logs
    // path  "versions.yml"                       , emit: versions

    tuple val(meta), path("*.STAR.genome.bam")       , optional:true, emit: bam_star
    tuple val(meta), path("${meta.id}.genome.bam")    , optional:true, emit: bam_genome
    tuple val(meta), path("${meta.id}.genome.sorted.bam")    , optional:true, emit: bam_genome_sorted
    tuple val(meta), path("${meta.id}.genome.sorted.bam.bai")    , optional:true, emit: bam_genome_sorted_bai
    tuple val(meta), path("${meta.id}.transcript.bam"), optional:true, emit: bam_transcript
    tuple val(meta), path("${meta.id}.transcript.sorted.bam"), optional:true, emit: bam_transcript_sorted
    tuple val(meta), path("${meta.id}.transcript.sorted.bam.bai"), optional:true, emit: bam_transcript_sorted_bai

    // flag
    // --temporary-folder ./tmp/
    // results in ./tpm//sampleID when comand is running

    // --alignments option allows using any alliner but instead of fastq provide .bam file
    // https://github.com/deweylab/RSEM?tab=readme-ov-file#using-an-alternative-aligner
    // --output-genome-bam option creates .bam sorted by genome coordinates
    // --sort-bam-by-coordinate sort using included version of samtools and create index
    // not shure if any output .bam from RSEM is useful
    // --no-bam-output prevents outputing any BAM file
    """
    INDEX=`find -L ./ -name "*.grp" | sed 's/\\.grp\$//'`
    rsem-calculate-expression \\
    --num-threads $task.cpus \\
    --no-bam-output \\
    --temporary-folder ./tmp/ \\
    --strandedness none \\
    --alignments --paired-end $bam \\
    \$INDEX \\
    $meta.id

    """
}
