process MERGE_FQ {
    publishDir params.outdir + "/merged_fastq", mode:'copy'
    tag "MERGE_FQ on $sample"

    input:
    tuple val(sample), path(R1), path(R2)
    output:
    tuple val(sample), path("${sample}_merged_R{1,2}.fastq.gz"), emit: reads
    script:
    """
    cat ${ R1.collect{ it }.sort().join(" ") } > ${sample}_merged_R1.fastq.gz
    cat ${ R2.collect{ it }.sort().join(" ") } > ${sample}_merged_R2.fastq.gz
    """
}
