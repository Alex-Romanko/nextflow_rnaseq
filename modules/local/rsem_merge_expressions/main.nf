process RSEM_MERGE_EXPRESSIONS {
    tag "RSEM_MERGE_EXPRESSIONS"
    publishDir params.outdir + "/rsem_expressions/merged_counts", mode:'copy'

    input:
    path genes
    path isoforms

    output:
    path "rsem.merged.gene_counts.tsv"      , emit: counts_gene
    path "rsem.merged.gene_tpm.tsv"         , emit: tpm_gene
    path "rsem.merged.gene_fpkm.tsv"         , emit: fpkm_gene
    path "rsem.merged.transcript_counts.tsv", optional:true, emit: counts_transcript
    path "rsem.merged.transcript_tpm.tsv"   , optional:true, emit: tpm_transcript
    path "rsem.merged.transcript_fpkm.tsv"   , optional:true, emit: fpkm_transcript

    script:
    def single_genes = genes.getAt(0)
    def single_isoforms = isoforms.getAt(0)


    """
    # GENES
    mkdir -p tmp/genes
    # extract id columns and length
    cut -f 1,2,3,4 $single_genes > gene_ids.txt

    for fileid in $genes; do
    samplename=`basename \$fileid | sed s/\\.genes.results\$//g`

    # extract counts
    echo \$samplename > tmp/genes/\${samplename}.counts.txt
    cut -f 5 \${fileid} | tail -n+2 >> tmp/genes/\${samplename}.counts.txt

    # extract TPM
    echo \$samplename > tmp/genes/\${samplename}.tpm.txt
    cut -f 6 \${fileid} | tail -n+2 >> tmp/genes/\${samplename}.tpm.txt

    # extract FPKM
    echo \$samplename > tmp/genes/\${samplename}.fpkm.txt
    cut -f 7 \${fileid} | tail -n+2 >> tmp/genes/\${samplename}.fpkm.txt
    done

    # ISOFORMS
    mkdir -p tmp/isoforms
    # extract id columns and length
    cut -f 1,2,3,4 $single_isoforms > isoforms_ids.txt

    for fileid in $isoforms; do
    samplename=`basename \$fileid | sed s/\\.isoforms.results\$//g`

    # extract counts
    echo \$samplename > tmp/isoforms/\${samplename}.counts.txt
    cut -f 5 \${fileid} | tail -n+2 >> tmp/isoforms/\${samplename}.counts.txt

    # extract TPM
    echo \$samplename > tmp/isoforms/\${samplename}.tpm.txt
    cut -f 6 \${fileid} | tail -n+2 >> tmp/isoforms/\${samplename}.tpm.txt

    # extract FPKM
    echo \$samplename > tmp/isoforms/\${samplename}.fpkm.txt
    cut -f 7 \${fileid} | tail -n+2 >> tmp/isoforms/\${samplename}.fpkm.txt
    done

    paste gene_ids.txt tmp/genes/*.counts.txt > rsem.merged.gene_counts.tsv
    paste gene_ids.txt tmp/genes/*.tpm.txt > rsem.merged.gene_tpm.tsv
    paste gene_ids.txt tmp/genes/*.fpkm.txt > rsem.merged.gene_fpkm.tsv

    paste isoforms_ids.txt tmp/isoforms/*.counts.txt > rsem.merged.transcript_counts.tsv
    paste isoforms_ids.txt tmp/isoforms/*.tpm.txt > rsem.merged.transcript_tpm.tsv
    paste isoforms_ids.txt tmp/isoforms/*.fpkm.txt > rsem.merged.transcript_fpkm.tsv
    """
}
