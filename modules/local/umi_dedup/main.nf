process UMITOOLS_DEDUP {
    tag "UMITOOLS_DEDUP $sample_id"
    label "process_medium"


    input:
    tuple val(sample_id), path(bam), path(bai)
    val get_output_stats

    output:
    tuple val(sample_id), path("${sample_id}.dedup_UMI.bam")     , emit: bam
    tuple val(sample_id), path("*.log")             , emit: log
    tuple val(sample_id), path("*edit_distance.tsv"), optional:true, emit: tsv_edit_distance
    tuple val(sample_id), path("*per_umi.tsv")      , optional:true, emit: tsv_per_umi
    tuple val(sample_id), path("*per_position.tsv") , optional:true, emit: tsv_umi_per_position


    script:
    def args = task.ext.args ?: ''
    stats = get_output_stats ? "--output-stats ${sample_id}" : ""

    """
    PYTHONHASHSEED=0 umi_tools \\
        dedup \\
        -I $bam \\
        -S ${sample_id}.dedup_UMI.bam \\
        -L ${sample_id}.log \\
        --paired \\
        $stats \\
        $args
    """

    // MPLCONFIGDIR="./tmp"
    // mkdir MPLCONFIGDIR
//  umi_tools dedup -I ./STAR/${sample}Aligned.sortedByCoord.out.bam -S ./STAR/${sample}_dedup_UMI.bam --paired --multimapping-detection-method=NH
}
