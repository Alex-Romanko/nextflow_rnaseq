process SAMTOOLS_SORT {
    publishDir params.outdir, mode:'copy'
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.csi"), emit: csi, optional: true

    script:
    def bamFileName = bam.getName()
    def bamSuffixe = bamFileName - meta - ~/\.bam$/

    """
    samtools sort \\
        $bam \\
        -@ $task.cpus \\
        -o ${meta.id}${bamSuffixe}.sorted.bam \\

    """
}
