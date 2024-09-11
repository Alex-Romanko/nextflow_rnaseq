process STAR_FUSION_STAR {
    tag "STAR_FUSION_STAR on $meta.id"
    label 'process_high'

    publishDir params.outdir + "/results_fusion/star_fusiob_basic", mode:'copy'


    input:
    tuple val(meta), path(reads), path(junction)
    path reference

    output:
    tuple val(meta), path("*.fusion_predictions.tsv")                   , emit: fusions
    tuple val(meta), path("*.abridged.tsv")                             , emit: abridged
    tuple val(meta), path("*.coding_effect.tsv")     , optional: true   , emit: coding_effect

    script:
    def fastq = "--left_fq ${reads[0]} --right_fq ${reads[1]}"
    def args = task.ext.args ?: ''
    def ctat_lib = params.ctat_build ? "${reference}/ctat_genome_lib_build_dir" : "${reference}"
    def prefix = "${meta.id}"

    """
    set -eou pipefail


    # list all files in the container
    echo "- - - - - -"
    echo "the genome lib is file is" $ctat_lib
    ls -alh $ctat_lib/ref_genome.fa.star.idx
    ls -alh
    echo "- - - - - -"

    STAR-Fusion \\
    --genome_lib_dir $ctat_lib \\
    $fastq \\
    -J $junction \\
    --CPU $task.cpus \\
    --examine_coding_effect \\
    --output_dir . \\
    $args

    mv star-fusion.fusion_predictions.tsv ${prefix}.starfusion.fusion_predictions.tsv
    mv star-fusion.fusion_predictions.abridged.tsv ${prefix}.starfusion.abridged.tsv
    mv star-fusion.fusion_predictions.abridged.coding_effect.tsv ${prefix}.starfusion.abridged.coding_effect.tsv
    """

}
