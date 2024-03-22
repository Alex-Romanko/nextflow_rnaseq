process SAMTOOLS_SORT {
    publishDir params.outdir, mode:'copy'
    tag "$sample_id"
    label 'process_medium'
    cpus 1

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("*.bam"), emit: bam
    tuple val(sample_id), path("*.csi"), emit: csi, optional: true

    script:
    def bamFileName = bam.getName()
    def bamSuffixe = bamFileName - sample_id - ~/\.bam$/

    """
    samtools sort \\
        $bam \\
        -@ $task.cpus \\
        -o ${sample_id}${bamSuffixe}.sorted.bam \\

    """
}
