#!/bin/bash

set -ev

VERSION=`cat VERSION.txt`

docker buildx build -t alexromanko/mamba_rnaseq:${VERSION} .
docker buildx build -t alexromanko/mamba_rnaseq:latest .
