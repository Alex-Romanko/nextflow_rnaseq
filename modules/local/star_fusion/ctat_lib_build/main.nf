process CTAT_LIB_BUILD {
    tag "CTAT_LIB_BUILD on $fasta"
    label 'process_high_long'
    storeDir "$projectDir/data/ctat_genome_lib_build_dir"


    input:
    path fasta
    path gtf

    // tuple val(meta), path(fasta)
    // tuple val(meta2), path(gtf)

    output:
    path "ctat_genome_lib_build_dir"  , emit: ctat_genome_lib

    script:
    def prep_genome_lib =  "/usr/local/src/STAR-Fusion/ctat-genome-lib-builder/prep_genome_lib.pl"
    def args = task.ext.args ?: ''
    def read_length = task.ext.read_length ?: '150'

    """
    ## export TMPDIR=/tmp
    mkdir ./tmp
    export TMPDIR="./tmp"
    wget http://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam34.0/Pfam-A.hmm.gz --no-check-certificate
    wget https://github.com/FusionAnnotator/CTAT_HumanFusionLib/releases/download/v0.3.0/fusion_lib.Mar2021.dat.gz -O CTAT_HumanFusionLib_Mar2021.dat.gz --no-check-certificate
    wget https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/AnnotFilterRule.pm -O AnnotFilterRule.pm --no-check-certificate
    wget https://www.dfam.org/releases/Dfam_3.4/infrastructure/dfamscan/homo_sapiens_dfam.hmm --no-check-certificate
    wget https://www.dfam.org/releases/Dfam_3.4/infrastructure/dfamscan/homo_sapiens_dfam.hmm.h3f --no-check-certificate
    wget https://www.dfam.org/releases/Dfam_3.4/infrastructure/dfamscan/homo_sapiens_dfam.hmm.h3i --no-check-certificate
    wget https://www.dfam.org/releases/Dfam_3.4/infrastructure/dfamscan/homo_sapiens_dfam.hmm.h3m --no-check-certificate
    wget https://www.dfam.org/releases/Dfam_3.4/infrastructure/dfamscan/homo_sapiens_dfam.hmm.h3p --no-check-certificate
    gunzip Pfam-A.hmm.gz && hmmpress Pfam-A.hmm
    $prep_genome_lib \\
        --genome_fa $fasta \\
        --gtf $gtf \\
        --annot_filter_rule AnnotFilterRule.pm \\
        --fusion_annot_lib CTAT_HumanFusionLib_Mar2021.dat.gz \\
        --pfam_db Pfam-A.hmm \\
        --dfam_db homo_sapiens_dfam.hmm \\
        --max_readlength $read_length \\
        --CPU $task.cpus
    rm -r ./tmp
    """

}
// process CTAT_LIB_BUILD {
//     tag "CTAT_LIB_BUILD on $fasta"
//     label 'process_high'
//     storeDir "$projectDir/data/ctat_genome_lib_build_dir"



//     input:
//     path fasta
//     path gtf, name: 'GRCh38.gencode.v44.annotation.gtf'
//     path ctat_source

//     output:
//     path "ctat_genome_lib_build_dir"        , emit: ctat_genome_lib

//     script:
//     // def args = task.ext.args ?: ''

//     """
//     /usr/local/src/STAR-Fusion/ctat-genome-lib-builder/prep_genome_lib.pl \\
//     --genome_fa $fasta  \\
//     --gtf $gtf \\
//     --fusion_annot_lib $ctat_source/fusion_annot_lib.gz \\
//     --annot_filter_rule $ctat_source/AnnotFilterRule.pm \\
//     --dfam_db human \\
//     --pfam_db current \\
//     --human_gencode_filter \\
//     --CPU $task.cpus
//     ## --is_grch38

//     find . -name "ctat_genome_lib_build_dir" -type d

//     """

// }
