process SAMTOOLS_INDEX {
    tag "SAMTOOLS_INDEX on $meta.id"
    label 'process_low'
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bai") , optional:true, emit: bai
    // tuple val(meta), path("*.csi") , optional:true, emit: csi
    // tuple val(meta), path("*.crai"), optional:true, emit: crai


    script:
    // def args = task.ext.args ?: ''
    """
    samtools \\
        index \\
        -@ $task.cpus \\
        ${bam} ${bam}.bai

    """

}
