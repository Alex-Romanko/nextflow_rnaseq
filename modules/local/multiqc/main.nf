process MULTIQC {
    label 'process_single'
    publishDir params.multiqc, mode:'copy'
    tag 'MultiQC'
    scratch '$TMPDIR'
    stageOutMode 'move'

    input:
    path ("fastqc/*")
    path ("star/*")
    // path ("fastp/*")
    // path ("umi_extract/*")
    path ("rsem/*")
    path "config"

    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , optional:true, emit: data
    path "*_plots"             , optional:true, emit: plots

    script:
    def args = task.ext.args ?: ''
    // def extra_config = extra_multiqc_config ? "--config $extra_multiqc_config" : ''
    """

    multiqc \\
        -o multiqc_report.html \\
        --config $config \\
        $args \\
        .
    """
}





    // cp $config/* .
    // echo "custom_logo: \$PWD/logo.png" >> multiqc_config.yaml
    // multiqc -o multiqc_report.html .
