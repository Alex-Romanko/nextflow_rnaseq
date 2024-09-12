process FASTP {
    tag "FASTP on $meta.id"
    label 'process_medium'


    input:
    tuple val(meta), path(reads)
    // path  adapter_fasta

    output:
    tuple val(meta), path("${prefix}*{1,2}.fastq.gz") , emit: reads
    tuple val(meta), path('*.json')           , optional:true  , emit: json
    tuple val(meta), path('*.html')           , optional:true  , emit: html
    tuple val(meta), path('*.log')            , optional:true  , emit: log
    tuple val(meta), path('*.fail.fastq.gz')  , optional:true  , emit: reads_fail
    tuple val(meta), path('*.merged.fastq.gz'), optional:true  , emit: reads_merged

    script:
    // if no external arguments run fastp only for quality control, no trimming allowed
    def args = task.ext.args ?: '-Q -L -A -G'
    prefix = task.ext.prefix ?: "${meta.id}"

    // def adapter_list = adapter_fasta ? "--adapter_fasta ${adapter_fasta}" : ""
    // Added soft-links to original fastqs for consistent naming in MultiQC
    // Use single ended for interleaved. Add --interleaved_in in config.
    """
    fastp \\
    --thread $task.cpus \\
    -i ${reads[0]} \\
    -I ${reads[1]} \\
    -o ${prefix}.fastp_R1.fastq.gz \\
    -O ${prefix}.fastp_R2.fastq.gz \\
    --json ${prefix}.fastp.json \\
    --html ${prefix}.fastp.html \\
    $args
    """
}
