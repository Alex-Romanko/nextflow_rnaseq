process STAR_FUSION_MERGE_TSV {
    tag "STAR_FUSION_MERGE"
    label 'process_single'
    publishDir params.outdir + "/results_fusion/", mode:'copy'

    input:
    path fusions
    val prefix

    output:
    path "*.tsv"      , emit: fusions_tsv

    script:

    """
    merge_star_tsv.R ${fusions}
    mv merged.tsv ${prefix}.merged.tsv
    """
}
