process RSEM_PREPAREREFERENCE {
    storeDir "$projectDir/data/RSEM_reference"
    // publishDir params.outdir + "/RSEM_reference", mode:'copy'
    label 'process_high'
    // maxForks 1
    tag "$fasta"

    input:
    path fasta
    path gtf
    path star

    output:
    path "star"           , emit: index
    path "*transcripts.fa", emit: transcript_fasta

    """
    rsem-prepare-reference \\
    --gtf $gtf \\
    --num-threads 8 \\
    $fasta \\
    star/genome

    cp star/genome.transcripts.fa .


    """
}
