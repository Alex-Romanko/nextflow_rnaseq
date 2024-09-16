process STAR_FUSION_FIINSPECTOR {
    tag "FIINSPECTOR on $meta.id"
    label 'process_high'
    publishDir params.outdir + "/results_fusion/fiinspector", mode:'copy'
    // do not fail if no fusion found
    errorStrategy = { task.exitStatus = 1 ? 'ignore' : 'finish' }
    scratch '$TMPDIR'
    stageOutMode 'move'


    input:
    tuple val(meta), path(reads), path(junction)
    path reference

    output:
    tuple val(meta), path("*.fusion_predictions.tsv")                   , emit: fusions
    tuple val(meta), path("*.abridged.tsv")                             , emit: abridged
    tuple val(meta), path("*.coding_effect.tsv")     , optional: true   , emit: coding_effect
    tuple val(meta), path("*FusionInspector-inspect"), optional: true, emit: fi_inspect
    tuple val(meta), path("*FusionInspector-validate"), optional: true, emit: fi_validate
    tuple val(meta), path("*.FusionInspector.log")     , optional: true   , emit: fi_log
    tuple val(meta), path("*.FusionInspector.fusions.tsv")     , optional: true   , emit: fi_fusions
    tuple val(meta), path("*.FusionInspector.fusions.abridged.tsv")     , optional: true   , emit: fi_fusions_abridged


// FusionInspector.log

    script:
    def fastq = "--left_fq ${reads[0]} --right_fq ${reads[1]}"
    def args = task.ext.args ?: ''
    // def ctat_lib = params.ctat_build ? "${reference}/ctat_genome_lib_build_dir" : "${reference}"
    def ctat_lib = "${reference}"

    def prefix = "${meta.id}"

    """
    set -eou pipefail
    REFERENCE=`find -L ./ -name "ctat_genome_lib_build_dir" -type d`

    # list all files in the container
    echo "- - - - - -"
    echo "the genome lib is file is" $ctat_lib
    ls -alh $ctat_lib/ref_genome.fa.star.idx
    ls -alh
    echo "- - - - - -"


    STAR-Fusion --genome_lib_dir $ctat_lib \\
    --chimeric_junction $junction \\
    $fastq \\
    --CPU $task.cpus \\
    --FusionInspector validate \\
    --examine_coding_effect \\
    --denovo_reconstruct \\
    --output_dir . \\
    $args


    [ -f star-fusion.fusion_predictions.tsv ] && mv star-fusion.fusion_predictions.tsv ${prefix}.starfusion.fusion_predictions.tsv
    [ -f star-fusion.fusion_predictions.abridged.tsv ] && mv star-fusion.fusion_predictions.abridged.tsv ${prefix}.starfusion.abridged.tsv
    [ -f star-fusion.fusion_predictions.abridged.coding_effect.tsv ] && mv star-fusion.fusion_predictions.abridged.coding_effect.tsv ${prefix}.starfusion.abridged.coding_effect.tsv
    [ -f FusionInspector.log ] && mv FusionInspector.log ${prefix}.FusionInspector.log

    [ ! -d FusionInspector-validate ] && mkdir ${prefix}_FusionInspector-validate && touch ./${prefix}_FusionInspector-validate/finspector.FusionInspector.fusions.tsv && touch ./${prefix}_FusionInspector-validate/finspector.FusionInspector.fusions.abridged.tsv

    [ -d FusionInspector-validate ] && mv FusionInspector-validate ${prefix}_FusionInspector-validate
    cp ${prefix}_FusionInspector-validate/finspector.FusionInspector.fusions.tsv ./${prefix}.FusionInspector.fusions.tsv
    cp ${prefix}_FusionInspector-validate/finspector.FusionInspector.fusions.abridged.tsv ./${prefix}.FusionInspector.fusions.abridged.tsv
    """

}
