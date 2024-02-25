#!/bin/bash

set -ev

VERSION=`cat VERSION.txt`

docker buildx build -t alex-romanko/mamba_rnaseq:${VERSION} .
docker buildx build -t alex-romanko/mamba_rnaseq:latest .
