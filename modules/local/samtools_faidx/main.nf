process SAMTOOLS_FAIDX {
    tag "SAMTOOLS_INDEX on $input"
    label 'process_low'


    input:
    path(input)

    output:

    path "${input}.fai", emit: fasta_index


    script:
    """
    samtools \\
        faidx \\
        ${input} ${input}.fai

    """

}
