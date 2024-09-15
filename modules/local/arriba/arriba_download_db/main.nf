process ARRIBA_DOWNLOAD_DB {
    tag "ARRIBA_DOWNLOAD_DB"
    label 'process_single'
    storeDir "${params.storeDir}/data/arriba_db"

    output:
    path "*"      , emit: arriba_db

    script:

    """
    wget https://github.com/suhrig/arriba/releases/download/v2.4.0/arriba_v2.4.0.tar.gz -O arriba_v2.4.0.tar.gz --no-check-certificate
    tar -xzvf arriba_v2.4.0.tar.gz
    rm arriba_v2.4.0.tar.gz
    mv arriba_v2.4.0/database/* .
    rm -r arriba_v2.4.0
    """
}
