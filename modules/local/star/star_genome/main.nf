process STAR_GENOMEGENERATE {
    tag "$fasta"
    label 'process_high'
    storeDir "${params.storeDir}/data/STAR_index"
    scratch '$TMPDIR'
    stageOutMode 'move'
    // publishDir params.outdir + "/STAR_genome", mode:'copy'

    // label 'process_high'
    input:
    path fasta
    path gtf

    output:
    path "star"        , emit: genome_index
    // path "versions.yml", emit: versions


    script:
    // def args = task.ext.args ?: ''
    // def args_list = args.tokenize()
    // def avaleble_mem = "60"
    // def memory = task.memory ? "--limitGenomeGenerateRAM ${avaleble_mem.toBytes() - 100000000}" : ''
    def cpus = 8
    // def memory = task.memory ? "--limitGenomeGenerateRAM ${task.memory.toBytes() - 100000000}" : ''

    """
    samtools faidx $fasta

    mkdir star
    STAR \\
    --runMode genomeGenerate \\
    --genomeDir star/ \\
    --genomeFastaFiles $fasta \\
    --sjdbGTFfile $gtf \\
    --runThreadN $cpus
    ## --sjdbGTFtagExonParentTranscript Parent \\ # for gff3 annotations

    """

}
