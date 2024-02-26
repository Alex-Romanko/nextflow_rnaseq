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
https://www.nextflow.io/docs/latest/getstarted.html
