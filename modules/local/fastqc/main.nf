process FASTQC {

    tag "FASTQC on $meta.id"
    label 'process_medium'


    input:
    tuple val(meta), path(reads)

    output:
    // path "fastqc_${meta.id}_logs", emit: logs
    path "${meta.id}*.zip" , optional:true, emit: zip
    path "${meta.id}*.html", optional:true, emit: html

    script:

    def memory_in_mb = MemoryUnit.of("${task.memory}").toUnit('MB')
    // FastQC memory value allowed range (100 - 10000)
    def fastqc_memory = memory_in_mb > 10000 ? 10000 : (memory_in_mb < 100 ? 100 : memory_in_mb)

    """
    mkdir fastqc_${meta.id}_logs
    fastqc -o fastqc_${meta.id}_logs -f fastq -q ${reads} --threads $task.cpus --memory $fastqc_memory
    mv fastqc_${meta.id}_logs/* .
    """
}
