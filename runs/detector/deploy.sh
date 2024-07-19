#!/bin/bash

PROJECT="mztn-seccamp-2024"

gcloud auth configure-docker asia-northeast1-docker.pkg.dev
docker build -t detector .
docker tag detector asia-northeast1-docker.pkg.dev/$PROJECT/containers-$ID/detector
docker push asia-northeast1-docker.pkg.dev/$PROJECT/containers-$ID/detector
