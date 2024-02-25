process TRIMGALORE {
    tag "TRIMGALORE on $sample_id"
    label 'process_high'
    publishDir params.outdir + "/trim_galore_logs", mode:'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*{3prime,5prime,trimmed,val}*.fq.gz"), emit: reads
    tuple val(sample_id), path("*report.txt")                        , emit: log     , optional: true
    tuple val(sample_id), path("*unpaired*.fq.gz")                   , emit: unpaired, optional: true
    tuple val(sample_id), path("*.html")                             , emit: html    , optional: true
    tuple val(sample_id), path("*.zip")                              , emit: zip     , optional: true


    script:
    def args = task.ext.args ?: ''
    // Calculate number of --cores for TrimGalore based on value of task.cpus
    // See: https://github.com/FelixKrueger/TrimGalore/blob/master/Changelog.md#version-060-release-on-1-mar-2019
    // See: https://github.com/nf-core/atacseq/pull/65
    def cores = 1
    if (task.cpus) {
        cores = (task.cpus as int) - 4
        if (cores < 1) cores = 1
        if (cores > 8) cores = 8
    }

    """
    [ ! -f  ${sample_id}_1.fastq.gz ] && ln -s ${reads[0]} ${sample_id}_1.fastq.gz
    [ ! -f  ${sample_id}_2.fastq.gz ] && ln -s ${reads[1]} ${sample_id}_2.fastq.gz
    trim_galore \\
    $args \\
    --cores $cores \\
    --paired \\
    --gzip \\
    ${sample_id}_1.fastq.gz \\
    ${sample_id}_2.fastq.gz

    """


}
