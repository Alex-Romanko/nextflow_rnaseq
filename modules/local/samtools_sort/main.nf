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
    // path  "versions.yml"          , emit: versions

    // when:
    // task.ext.when == null || task.ext.when

    script:
    def bamFileName = bam.getName()
    def bamSuffixe = bamFileName - sample_id - ~/\.bam$/
    // def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${sample_id}"
    // if ("$bam" == "${prefix}.bam") error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    """
    samtools sort \\
        $bam \\
        -@ $task.cpus \\
        -o ${sample_id}${bamSuffixe}.sorted.bam \\

    """

    // samtools sort \\
    //     $args \\
    //     -@ $task.cpus \\
    //     -o ${sample_id}.${bamSuffixe}.sorted.bam \\
    //     -T $prefix \\
    //     $bam
}
