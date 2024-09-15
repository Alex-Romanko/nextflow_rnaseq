# Dockerfile for RNA-seq pipeline
# Initially obtained from https://github.com/broadinstitute/gtex-pipeline
FROM ubuntu:22.04
MAINTAINER romanko.aleksandr.a@gmail.com

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y software-properties-common && \
    apt-get update && apt-get install -y \
    build-essential \
    openjdk-8-jdk \
    apt-utils \
    gcc \
    g++ \
    gawk \
    cmake \
    curl \
    git \
    libboost-all-dev \
    libbz2-dev \
    libcurl3-dev \
    libhdf5-serial-dev \
    liblzma-dev \
    libncurses5-dev \
    libssl-dev \
    openjdk-8-jdk \
    python3 \
    python3-pip \
    unzip \
    vim-common \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/


#-----------------------------
# Pipeline components
#-----------------------------



# htslib
ENV hstlib_version=1.18

RUN cd /opt && \
    hstlib_url="https://github.com/samtools/htslib/releases/download/${hstlib_version}/htslib-${hstlib_version}.tar.bz2" && \
    wget --no-check-certificate $hstlib_url && \
    tar -xf htslib-${hstlib_version}.tar.bz2 && \
    rm htslib-${hstlib_version}.tar.bz2 && \
    cd htslib-${hstlib_version} && \
    ./configure --enable-libcurl --enable-s3 --enable-plugins --enable-gcs && \
    make && \
    make install && \
    make clean

# samtools
ENV samtools_version=1.18

RUN cd /opt && \
    samtools_url="https://github.com/samtools/samtools/releases/download/${samtools_version}/samtools-${samtools_version}.tar.bz2" && \
    wget --no-check-certificate $samtools_url && \
    tar -xf samtools-${samtools_version}.tar.bz2 && \
    rm samtools-${samtools_version}.tar.bz2 && \
    cd samtools-${samtools_version} && \
    ./configure --with-htslib=/opt/htslib-${hstlib_version} && \
    make && \
    make install && \
    make clean

## STAR
ENV star_version=2.7.11a

RUN cd /opt && \
    star_url="https://github.com/alexdobin/STAR/archive/${star_version}.tar.gz" && \
    wget --no-check-certificate $star_url && \
    tar -xf${star_version}.tar.gz && \
    rm ${star_version}.tar.gz

ENV PATH /opt/STAR-${star_version}/bin/Linux_x86_64_static:$PATH

## RSEM
ENV rsem_version=1.3.3

RUN cd /opt && \
    rsem_url="https://github.com/deweylab/RSEM/archive/v${rsem_version}.tar.gz" && \
    wget --no-check-certificate $rsem_url && \
    tar -xvf v${rsem_version}.tar.gz && \
    rm v${rsem_version}.tar.gz && \
    cd RSEM-${rsem_version} && \
    make
ENV PATH /opt/RSEM-${rsem_version}:$PATH

## bamtools
ENV bamtools_version=2.5.2

RUN cd /opt && \
    bamtools_url="https://github.com/pezmaster31/bamtools/archive/v${bamtools_version}.tar.gz" && \
    wget --no-check-certificate $bamtools_url && \
    tar -xf v${bamtools_version}.tar.gz && \
    rm v${bamtools_version}.tar.gz && \
    cd bamtools-${bamtools_version} && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    make clean

ENV LD_LIBRARY_PATH /usr/local/lib/bamtools:$LD_LIBRARY_PATH

# ## bedtools # error deaoring compillation
# ## bedtools src/utils/general/ParseTools.h:57:9: error: 'uint32_t' was not declared in this scope
# ## could be solved via addind '#include <cstdint>' to the file "src/utils/general/ParseTools.h"

# ENV bedtools_version=2.31.0

# RUN cd /opt && \
#     bedtools_url="https://github.com/arq5x/bedtools2/releases/download/v${bedtools_version}/bedtools-${bedtools_version}.tar.gz" && \
#     wget --no-check-certificate ${bedtools_url} && \
#     tar -xf bedtools-${bedtools_version}.tar.gz && \
#     rm bedtools-${bedtools_version}.tar.gz && \
#     cd bedtools2 && \
#     make && \
#     make install && \
#     make clean

## bedtools bin
ENV bedtools_version=2.31.0

RUN cd /opt && \
    bedtools_url="https://github.com/arq5x/bedtools2/releases/download/v${bedtools_version}/bedtools.static" && \
    mkdir bedtools-${bedtools_version} && \
    cd bedtools-${bedtools_version} && \
    wget --no-check-certificate ${bedtools_url} && \
    mv bedtools.static bedtools && \
    chmod a+x bedtools

ENV PATH /opt/bedtools-${bedtools_version}:$PATH



# FastQC
ENV fastqc_version=0.12.1

RUN cd /opt && \
    fastqc_url="https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${fastqc_version}.zip" && \
    wget --no-check-certificate ${fastqc_url} && \
    unzip fastqc_v${fastqc_version}.zip && \
    mv FastQC FastQC-${fastqc_version} && \
    cd FastQC-${fastqc_version} && \
    chmod 775 fastqc
ENV PATH /opt/FastQC-${fastqc_version}:$PATH

# RNA-SeQC
ENV rnaseqc_version=2.4.2

RUN mkdir /opt/rnaseqc && \
    rnaseqc_url="https://github.com/getzlab/rnaseqc/releases/download/v${rnaseqc_version}/rnaseqc.v${rnaseqc_version}.linux.gz" && \
    cd /opt/rnaseqc && \
    wget $rnaseqc_url && \
    gunzip rnaseqc.v${rnaseqc_version}.linux.gz && mv rnaseqc.v${rnaseqc_version}.linux rnaseqc && chmod 775 rnaseqc
RUN pip3 install rnaseqc
ENV PATH /opt/rnaseqc:$PATH



# python modules
RUN pip3 install --upgrade pip setuptools
RUN pip3 install tables numpy pandas scipy pyarrow matplotlib seaborn
# numpy dependencies:
RUN pip3 install pyBigWig

# UMI-TOOLS
RUN pip3 install umi_tools

# SeqKit
ENV seqkit_version=2.8.2
RUN cd /opt && \
    seqkit_url="https://github.com/shenwei356/seqkit/releases/download/v${seqkit_version}/seqkit_linux_amd64.tar.gz" && \
    wget --no-check-certificate ${seqkit_url} && \
    tar -zxvf seqkit*.tar.gz && \
    mv seqkit /usr/local/bin/ && \
    rm seqkit*.tar.gz && \
    cd /usr/local/bin/ && \
    chmod 775 seqkit

ENV fastp_version=0.23.4
RUN cd /opt && \
    fastp_url="http://opengene.org/fastp/fastp.${fastp_version}" && \
    wget --no-check-certificate ${fastp_url} && \
    mv fastp.${fastp_version} /usr/local/bin/fastp && \
    chmod 775 /usr/local/bin/fastp

# Arriba
ENV arriba_version=2.4.0
RUN cd /opt && \
    arriba_url="https://github.com/suhrig/arriba/releases/download/v${arriba_version}/arriba_v${arriba_version}.tar.gz" && \
    wget --no-check-certificate ${arriba_url} -O arriba_v${arriba_version}.tar.gz && \
    tar -xzvf arriba_v${arriba_version}.tar.gz && \
    rm arriba_v2.4.0.tar.gz && \
    cd arriba_v${arriba_version} && \
    make && \
    chmod 775 arriba && \
    mv arriba /usr/local/bin/ && \
    cd .. && \
    rm -r arriba_v2.4.0


# # bamsync ## from original pipeline
# COPY bamsync /opt/bamsync
# RUN cd /opt/bamsync && make
# ENV PATH /opt/bamsync:$PATH

# ## Picard tools
# RUN mkdir /opt/picard-tools && \
#     wget --no-check-certificate -P /opt/picard-tools/ https://github.com/broadinstitute/picard/releases/download/2.27.1/picard.jar

# # kallisto
# RUN cd /opt && \
#     wget https://github.com/pachterlab/kallisto/releases/download/v0.48.0/kallisto_linux-v0.48.0.tar.gz && \
#     tar -xf kallisto_linux-v0.48.0.tar.gz && rm kallisto_linux-v0.48.0.tar.gz
# ENV PATH $PATH:/opt/kallisto_linux-v0.48.0


# # UCSC tools
# RUN mkdir /opt/ucsc && \
#     wget --no-check-certificate -P /opt/ucsc/ http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bigWigToBedGraph && \
#     wget --no-check-certificate -P /opt/ucsc/ http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig && \
#     chmod 755 /opt/ucsc/*
# ENV PATH /opt/ucsc:$PATH


# # # gcloud
# # RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
# #     echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
# #     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
# #     apt-get update -y && apt-get install google-cloud-sdk -y

# # scripts
# COPY src src/
