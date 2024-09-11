process UMITOOLS_PREPAREFORRSEM {
    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path('*.bam'), emit: bam
    tuple val(meta), path('*.log'), optional:true, emit: log


    script:
    def args = task.ext.args ?: ''
    """
    umi_tools prepare-for-rsem \\
        --stdin=$bam \\
        --stdout=${meta.id}.prepare_for_rsem.bam \\
        --log=${meta.id}.prepare_for_rsem.log \\
        $args
    """
}
