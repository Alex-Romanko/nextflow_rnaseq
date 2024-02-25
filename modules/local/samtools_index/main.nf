process SAMTOOLS_INDEX {
    tag "SAMTOOLS_INDEX on $sample_id"
    label 'process_low'
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(sample_id), path(input)

    output:
    tuple val(sample_id), path("*.bai") , optional:true, emit: bai
    // tuple val(sample_id), path("*.csi") , optional:true, emit: csi
    // tuple val(sample_id), path("*.crai"), optional:true, emit: crai


    script:
    // def args = task.ext.args ?: ''
    """
    samtools \\
        index \\
        -@ 4 \\
        ${input} ${input}.bai

    """

}
