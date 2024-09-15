process ARRIBA_FUSION {
    tag "ARRIBA on $meta.id"
    label 'process_high'
    publishDir params.outdir+ "/results_fusion/arriba/", mode:'copy'
    scratch '$TMPDIR'
    stageOutMode 'move'

    input:
    tuple val(meta), path(reads)
    path fasta
    path gtf
    path index
    path arriba_db


    // input:
    // tuple val(meta), path(bam), path(bai), path(fusions)
    // tuple val(meta2), path(gtf)
    // tuple val(meta3), path(protein_domains)
    // tuple val(meta4), path(cytobands)

    output:
    tuple val(meta), path("*.fusions.tsv")          , emit: fusions
    tuple val(meta), path("*.fusions.discarded.tsv"), optional:true, emit: fusions_discard
    // tuple val(meta), path("*.pdf")          , emit: pdf


    script:
    // def args = task.ext.args ?: ''
    // def cytobands = cytobands ? " --cytobands=$cytobands" : ""
    // def prefix = task.ext.prefix ?: "${meta.id}"
    // def protein_domains = protein_domains ? "--proteinDomains=$protein_domains" : ""
    """

    BLACKLIST=`find -L ./ -name "blacklist_hg38_GRCh38_v2.4.0.tsv.gz"`
    KNOWN_FUSIONS=`find -L ./ -name "known_fusions_hg38_GRCh38_v2.4.0.tsv.gz"`
    PROREIN_DB=`find -L ./ -name "protein_domains_hg38_GRCh38_v2.4.0.gff3"`



    STAR \\
    --readFilesCommand zcat \\
    --runThreadN $task.cpus \\
    --genomeDir $index \\
    --genomeLoad NoSharedMemory \\
    --outStd BAM_Unsorted \\
    --outSAMtype BAM Unsorted \\
    --outSAMunmapped Within \\
    --outBAMcompression 0 \\
    --outFilterMultimapNmax 50 \\
    --peOverlapNbasesMin 10 \\
    --alignSplicedMateMapLminOverLmate 0.5 \\
    --alignSJstitchMismatchNmax 5 -1 5 5 \\
    --chimSegmentMin 10 \\
    --chimOutType WithinBAM HardClip \\
    --chimJunctionOverhangMin 10 \\
    --chimScoreDropMax 30 \\
    --chimScoreJunctionNonGTAG 0 \\
    --chimScoreSeparation 1 \\
    --chimSegmentReadGapMax 3 \\
    --chimMultimapNmax 50 \\
    --readFilesIn ${reads[0]} ${reads[1]} | arriba \\
    -x /dev/stdin \\
    -o ${meta.id}.fusions.tsv \\
    -O ${meta.id}.fusions.discarded.tsv \\
    -a $fasta \\
    -g $gtf \\
    -b \$BLACKLIST \\
    -k \$KNOWN_FUSIONS \\
    -t \$KNOWN_FUSIONS \\
    -p \$PROREIN_DB
    """



    // ## arriba \\
    // ## -x Aligned.out.bam \\
    // ## -o fusions.tsv \\
    // ## -O fusions.discarded.tsv \\
    // ## -a /path/to/assembly.fa \\
    // ## -g /path/to/annotation.gtf \\
    // ## -b /path/to/blacklist.tsv.gz \\
    // ## -k /path/to/known_fusions.tsv.gz \\
    // ## -t /path/to/known_fusions.tsv.gz \\
    // ## -p /path/to/protein_domains.gff3

    // draw_fusions.R \\
    //     --fusions=$fusions \\
    //     --alignments=$bam \\
    //     --output=${prefix}.pdf \\
    //     --annotation=${gtf} \\
    //     $cytobands \\
    //     $protein_domains \\
    //     $args

}
