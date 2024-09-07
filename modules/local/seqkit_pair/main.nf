process SEQKIT_PAIR_FQ {
    // publishDir params.outdir + "/merged_fastq", mode:'copy'
    tag "SEQKIT_PAIR on $meta.id"
    label 'process_medium'
    // label "process_single"
    // label "process_long"


    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*{1,2}.paired.fastq.gz")                  , emit: reads
    tuple val(meta), path("*{1,2}.unpaired.fastq.gz"), optional: true, emit: unpaired_reads

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
