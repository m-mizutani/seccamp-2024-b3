#!/bin/bash

PROJECT="mztn-seccamp-2024"

gcloud auth configure-docker asia-northeast1-docker.pkg.dev
docker build -t crawler --platform linux/amd64 .
docker tag crawler asia-northeast1-docker.pkg.dev/$PROJECT/containers-$ID/crawler
docker push asia-northeast1-docker.pkg.dev/$PROJECT/containers-$ID/crawler
