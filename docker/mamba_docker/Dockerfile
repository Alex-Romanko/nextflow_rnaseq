FROM mambaorg/micromamba:1.5.1
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes
# Dockerfile for RNA-seq pipeline
MAINTAINER romanko.aleksandr.a@gmail.com

RUN \
    micromamba install -y -n base -c defaults -c bioconda -c conda-forge \
    bedtools=2.31.0 \
    salmon=1.10.2 \
    fastqc=0.12.1 \
    multiqc=1.15 \
    numpy \
    pandas \
    scipy \
    pyarrow \
    typing-extensions \
    matplotlib \
    seaborn \
    pyBigWig \
    && micromamba clean -a -y

USER root
