process RSEM_CALCULATEEXPRESSION {
    label 'process_high'
    tag "$sample_id"
    publishDir params.outdir + "/rsem_expressions", mode:'copy'

    // label 'process_high'

    input:
    // tuple val(sample_id), path(reads)
    path index
    tuple val (sample_id), path(bam)

    output:
    tuple val(sample_id), path("*.genes.results")   , emit: counts_gene
    tuple val(sample_id), path("*.isoforms.results"), emit: counts_transcript
    tuple val(sample_id), path("*.stat")            , emit: stat
    // tuple val(sample_id), path("*.log")             , emit: logs
    // path  "versions.yml"                       , emit: versions

    tuple val(sample_id), path("*.STAR.genome.bam")       , optional:true, emit: bam_star
    tuple val(sample_id), path("${sample_id}.genome.bam")    , optional:true, emit: bam_genome
    tuple val(sample_id), path("${sample_id}.genome.sorted.bam")    , optional:true, emit: bam_genome_sorted
    tuple val(sample_id), path("${sample_id}.genome.sorted.bam.bai")    , optional:true, emit: bam_genome_sorted_bai
    tuple val(sample_id), path("${sample_id}.transcript.bam"), optional:true, emit: bam_transcript
    tuple val(sample_id), path("${sample_id}.transcript.sorted.bam"), optional:true, emit: bam_transcript_sorted
    tuple val(sample_id), path("${sample_id}.transcript.sorted.bam.bai"), optional:true, emit: bam_transcript_sorted_bai

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
    --num-threads 8 \\
    --output-genome-bam \\
    --sort-bam-by-coordinate \\
    --temporary-folder ./tmp/ \\
    --strandedness none \\
    --alignments --paired-end $bam \\
    \$INDEX \\
    $sample_id

    """
}
