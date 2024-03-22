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
    tuple val(sample_id), path("${sample_id}.transcript.bam"), optional:true, emit: bam_transcript

    // when:
    // task.ext.when == null || task.ext.when

    // script:
    // def args = task.ext.args   ?: ''

    // def strandedness = ''
    // if (sample_id.strandedness == 'forward') {
    //     strandedness = '--strandedness forward'
    // } else if (sample_id.strandedness == 'reverse') {
    //     strandedness = '--strandedness reverse'
    // }
    // def paired_end = sample_id.single_end ? "" : "--paired-end"



    // --strandednes ## For Illumina TruSeq Stranded protocols, please use 'reverse'. (Default: 'none')


    // INDEX=`find -L ./ -name "*.grp" | sed 's/\\.grp\$//'`
    // rsem-calculate-expression \\
    //     --num-threads 8 \\
    //     --temporary-folder ./tmp/ \\
    //     --strandedness reverse \\
    //     --paired-end \\
    // 	--alignments $bam \\
    //     $reads \\
    //     \$INDEX \\
    //     $sample_id


    // flag
    // --temporary-folder ./tmp/
    // results in ./tpm//sampleID when comand is running
    """
    INDEX=`find -L ./ -name "*.grp" | sed 's/\\.grp\$//'`
    rsem-calculate-expression \\
        --num-threads 8 \\
        --temporary-folder ./tmp/ \\
        --strandedness reverse \\
	--alignments --paired-end $bam \\
        \$INDEX \\
        $sample_id

    """
}
