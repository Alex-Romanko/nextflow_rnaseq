#!/bin/bash

set -ev

VERSION=`cat VERSION.txt`

docker buildx build -t alexromanko/rutils:${VERSION} .
docker buildx build -t alexromanko/rutils:latest .
