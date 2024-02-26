process RSEM_PREPAREREFERENCE {
    publishDir params.outdir + "/RSEM_reference", mode:'copy'
    storeDir "$projectDir/data/RSEM_reference"

    maxForks 1
    tag "$fasta"
    // label 'process_high'

    // conda "bioconda::rsem=1.3.3 bioconda::star=2.7.10a"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/mulled-v2-cf0123ef83b3c38c13e3b0696a3f285d3f20f15b:64aad4a4e144878400649e71f42105311be7ed87-0' :
    //     'biocontainers/mulled-v2-cf0123ef83b3c38c13e3b0696a3f285d3f20f15b:64aad4a4e144878400649e71f42105311be7ed87-0' }"

    input:
    path fasta
    path gtf
    path star

    output:
    path "star"           , emit: index
    path "*transcripts.fa", emit: transcript_fasta

    // when:
    // task.ext.when == null || task.ext.when

    // script:
    // def args = task.ext.args ?: ''
    // def args2 = task.ext.args2 ?: ''
    // def args_list = args.tokenize()

    // def memory = task.memory ? "--limitGenomeGenerateRAM ${task.memory.toBytes() - 100000000}" : ''
    """
    rsem-prepare-reference \\
    --gtf $gtf \\
    --num-threads 8 \\
    $fasta \\
    star/genome

    cp star/genome.transcripts.fa .

    """
}
