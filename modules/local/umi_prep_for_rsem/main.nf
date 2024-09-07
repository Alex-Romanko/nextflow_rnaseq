process UMITOOLS_PREPAREFORRSEM {
    tag "$sample_id"
    label 'process_medium'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id), path('*.bam'), emit: bam
    tuple val(sample_id), path('*.log'), optional:true, emit: log


    script:
    def args = task.ext.args ?: ''
    """
    umi_tools prepare-for-rsem \\
        --stdin=$bam \\
        --stdout=${sample_id}.prepare_for_rsem.bam \\
        --log=${sample_id}.prepare_for_rsem.log \\
        $args
    """
}
