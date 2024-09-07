process PICARD_SORTSAM {
    tag "SORT_SAM on $meta.id"
    label 'process_low'
    label "picard"

    publishDir params.outdir + "/picard_sort", mode:'copy'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.bai"), optional:true, emit: bai

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '--SORT_ORDER queryname'
    def bam_label = task.ext.bam_label ?: 'sorted.picard'

    // def avail_mem = 3072
    // if (!task.memory) {
    //     log.info '[Picard SortSam] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    // } else {
    //     avail_mem = (task.memory*1000*0.8).intValue()
    // }


    """
    mkdir ./tmp
    picard \\
        SortSam \\
        --INPUT $bam \\
        --OUTPUT ${meta.id}.${bam_label}.bam \\
        $args

    """
}

// java -Xmx8g -jar /home/ngs_bin/bin/picard.jar SortSam I=${sample}_dedup_sorted.bam o=${sample}_dedup_QuerySorted.bam SORT_ORDER=queryname CREATE_INDEX=false TMP_DIR=temp_sort
