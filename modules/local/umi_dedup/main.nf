process UMITOOLS_DEDUP {
    tag "UMITOOLS_DEDUP $meta.id"
    label "process_medium"


    input:
    tuple val(meta), path(bam), path(bai)
    val get_output_stats

    output:
    tuple val(meta), path("*.dedup_UMI.bam")     , emit: bam
    tuple val(meta), path("*.log")             , emit: log
    tuple val(meta), path("*edit_distance.tsv"), optional:true, emit: tsv_edit_distance
    tuple val(meta), path("*per_umi.tsv")      , optional:true, emit: tsv_per_umi
    tuple val(meta), path("*per_position.tsv") , optional:true, emit: tsv_umi_per_position


    script:
    def args = task.ext.args ?: ''
    stats = get_output_stats ? "--output-stats ${meta.id}" : ""

    """
    PYTHONHASHSEED=0 umi_tools \\
        dedup \\
        -I $bam \\
        -S ${meta.id}.dedup_UMI.bam \\
        -L ${meta.id}.log \\
        --paired \\
        $stats \\
        $args
    """

    // MPLCONFIGDIR="./tmp"
    // mkdir MPLCONFIGDIR
//  umi_tools dedup -I ./STAR/${sample}Aligned.sortedByCoord.out.bam -S ./STAR/${sample}_dedup_UMI.bam --paired --multimapping-detection-method=NH
}
