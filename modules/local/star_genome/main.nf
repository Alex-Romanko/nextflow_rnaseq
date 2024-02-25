process STAR_GENOMEGENERATE {
    tag "$fasta"
    publishDir params.outdir + "/STAR_genome", mode:'copy'

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

    // """
    // samtools faidx $fasta
    // NUM_BASES=`gawk '{sum = sum + \$2}END{if ((log(sum)/log(2))/2 - 1 > 14) {printf "%.0f", 14} else {printf "%.0f", (log(sum)/log(2))/2 - 1}}' ${fasta}.fai`

    // mkdir star
    // STAR \\
    // --runMode genomeGenerate \\
    // --genomeDir star/ \\
    // --genomeFastaFiles $fasta \\
    // --sjdbGTFfile $gtf \\
    // --runThreadN $task.cpus \\
    // --sjdbGTFtagExonParentTranscript Parent \\ # for gff3 annotations
    // --genomeSAindexNbases \$NUM_BASES \\
    // $memory \\
    // $args

    // """



}
