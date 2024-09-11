process UMITOOLS_EXTRACT {
    tag "UMI_EXTRACT on $meta.id"
    label "process_single"
    // label "process_long"


    input:
    tuple val(meta), path(reads)

    output:
    // tuple val(meta), path("*.fastq.gz"), emit: reads
    tuple val(meta), path("*.umi_extract_R{1,2}.fastq.gz"), emit: reads
    tuple val(meta), path("*.log")     , emit: log

    script:
    def pattern = task.ext.pattern ?: '--bc-pattern=NNNNNNNNNN'
    def args = task.ext.args ?: ''

// Вырезаю 8 нуклеотидов в начале R2 для последующего использования в качестве UMI
// (там расположен рандомный праймер, который вообще-то имеет длину 10, но можно предположить, что последние 2 нуклеотида на его 3'-конце всё же с матрицей совпадают).
// Использую UMI-tools.
// ts easy to do this in UMI-tools. Simple pass read2 to UMI-tools as its primary input and tell it to add the UMI sequence to read1 as a secondary input:
// umi-tools not designed to extract UMI only from read 2 https://github.com/CGATOxford/UMI-tools/issues/522
// should be fixed in later releases ... https://github.com/CGATOxford/UMI-tools/pull/630

    """
    umi_tools \\
    extract \\
    --extract-method=string \\
    -I ${reads[1]} \\
    $pattern \\
    --read2-in=${reads[0]} \\
    -S ${meta.id}.umi_extract_R2.fastq.gz \\
    --read2-out=${meta.id}.umi_extract_R1.fastq.gz \\
    --log ${meta.id}.umi_extract.log \\
    $args
    """

// umi_tools  extract --extract-method=string  -I ../../SRS85_S105_L004_R1_001.fastq.gz --bc-pattern2=NNNNNNNNNN --read2-in=../../SRS85_S105_L004_R2_001.fastq.gz  -S SRS85_S105_L004.correct.umi_extract_R1.fastq.gz --read2-out=SRS85_S105_L004.correct.umi_extract_R2.fastq.gz --log SRS85_merged.correct.umi_extract.log


//     umi_tools \\
//     extract \\
//     -I ${reads[0]} \\
//     --read2-in=${reads[1]} \\
//     -S ${meta}.umi_extract_R1.fastq.gz \\
//     --read2-out=${meta}.umi_extract_R2.fastq.gz \\
//     $args \\
//     $pattern \\
//     --extract-method=string \\
//     --log ${meta}.umi_extract.log
}
