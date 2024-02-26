#!/bin/bash

set -ev

VERSION=`cat VERSION.txt`

docker buildx build -t alexromanko/rnaseq:${VERSION} .
docker buildx build -t alexromanko/rnaseq:latest .
