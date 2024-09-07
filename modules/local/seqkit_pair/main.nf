process SEQKIT_PAIR_FQ {
    // publishDir params.outdir + "/merged_fastq", mode:'copy'
    tag "SEQKIT_PAIR on $sample_id"
    label 'process_medium'
    // label "process_single"
    // label "process_long"


    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}*{1,2}.paired.fastq.gz")                  , emit: reads
    tuple val(sample_id), path("${sample_id}*{1,2}.unpaired.fastq.gz"), optional: true, emit: unpaired_reads

    script:
    """
    seqkit \\
    pair \\
    -1 ${reads[0]} \\
    -2 ${reads[1]} \\
    -u \\
    --threads $task.cpus
    """
}
