#!/bin/bash

set -ev

VERSION=`cat VERSION.txt`

docker buildx build -t alex-romanko/rnaseq:${VERSION} .
docker buildx build -t alex-romanko/rnaseq:latest .
