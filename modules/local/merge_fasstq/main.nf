process MERGE_FQ {
    publishDir params.outdir + "/merged_fastq", mode:'copy'
    tag "MERGE_FQ on $meta.id"

    label 'process_low'

    input:
    tuple val(meta), path(R1), path(R2)
    output:
    tuple val(meta), path("*_merged_R{1,2}.fastq.gz"), emit: reads
    script:
    """
    cat ${ R1.collect{ it.toString() }.sort().join(" ") } > ${meta.id}_merged_R1.fastq.gz
    cat ${ R2.collect{ it.toString() }.sort().join(" ") } > ${meta.id}_merged_R2.fastq.gz
    """
}
