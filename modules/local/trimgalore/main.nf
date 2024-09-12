process TRIMGALORE {
    tag "TRIMGALORE on $meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*{3prime,5prime,trimmed,val}*.fq.gz"), emit: reads
    tuple val(meta), path("*report.txt")                        , emit: log     , optional: true
    tuple val(meta), path("*unpaired*.fq.gz")                   , emit: unpaired, optional: true
    tuple val(meta), path("*.html")                             , emit: html    , optional: true
    tuple val(meta), path("*.zip")                              , emit: zip     , optional: true


    script:
    def args = task.ext.args ?: ''
    // Calculate number of --cores for TrimGalore based on value of task.cpus
    // See: https://github.com/FelixKrueger/TrimGalore/blob/master/Changelog.md#version-060-release-on-1-mar-2019
    // See: https://github.com/nf-core/atacseq/pull/65
    def cores = 1
    if (task.cpus) {
        cores = (task.cpus as int) - 4
        if (cores < 8) cores = 1
        if (cores > 8) cores = 8
    }

    """
    [ ! -f  ${meta.id}_1.fastq.gz ] && ln -s ${reads[0]} ${meta.id}_1.fastq.gz
    [ ! -f  ${meta.id}_2.fastq.gz ] && ln -s ${reads[1]} ${meta.id}_2.fastq.gz
    trim_galore \\
    $args \\
    --cores $cores \\
    --paired \\
    --gzip \\
    ${meta.id}_1.fastq.gz \\
    ${meta.id}_2.fastq.gz

    """


}
