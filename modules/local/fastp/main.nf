process FASTP {
    tag "FASTP on $sample_id"
    label 'process_medium'


    input:
    tuple val(sample_id), path(reads)
    // path  adapter_fasta

    output:
    tuple val(sample_id), path("${sample_id}*{1,2}.fastq.gz") , emit: reads
    tuple val(sample_id), path('*.json')           , optional:true  , emit: json
    tuple val(sample_id), path('*.html')           , optional:true  , emit: html
    tuple val(sample_id), path('*.log')            , optional:true  , emit: log
    tuple val(sample_id), path('*.fail.fastq.gz')  , optional:true  , emit: reads_fail
    tuple val(sample_id), path('*.merged.fastq.gz'), optional:true  , emit: reads_merged

    script:
    // if no external arguments run fastp only for quality control, no trimming allowed
    def args = task.ext.args ?: '-Q -L -A -G'

    // def adapter_list = adapter_fasta ? "--adapter_fasta ${adapter_fasta}" : ""
    // Added soft-links to original fastqs for consistent naming in MultiQC
    // Use single ended for interleaved. Add --interleaved_in in config.
    """
    fastp \\
    --thread $task.cpus \\
    -i ${reads[0]} \\
    -I ${reads[1]} \\
    -o ${sample_id}.fastp_R1.fastq.gz \\
    -O ${sample_id}.fastp_R2.fastq.gz \\
    --json ${sample_id}.fastp.json \\
    --html ${sample_id}.fastp.html \\
    $args
    """
}
