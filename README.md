# The goal
Here is my initial attempt to create a nextflow pipeline for RNAseq. The main purpose of the repo is to study nextflow and its pipelines. 
# Java
The java version used for the pipeline is Temurin-17.0.10+7

How to install it on ubuntu: https://www.d4d.lt/how-to-install-adoptium-temurin-openjdk-17-on-ubuntu-22-04
# Docker
The pipeline uses docker container system

Installation guide of docker on ubuntu: https://docs.docker.com/engine/install/ubuntu/

Before beginning user shold build the container for the pipeline
```
cd ./docker/RNAseq
sudo ./build_docker.sh
```
# Install Nextflow
There are might be some issues with dependencies installation if only bare nextflow been installed. So there might be preferable to install full destribution from releases https://github.com/nextflow-io/nextflow/releases
```
wget -O nextflow https://github.com/nextflow-io/nextflow/releases/download/v23.10.1/nextflow-23.10.1-all
chmode +x nextflow
mv nextflow ~/bin
```


# Run the pipeline
```
sudo nextflow run main.nf --fastq_dir /path/to/directory/with/fastq/ --transcriptome_file /path/to/GenCode/GRCh38.p14.genome.fa --gtf_file /path/to/GenCode/gencode.v44.annotation.gtf
```
