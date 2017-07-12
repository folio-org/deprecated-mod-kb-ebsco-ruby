#!/bin/bash

set -e
set -x

docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

docker build -t ${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT .
image=$(docker images --format="{{.ID}}" | head -n 1)
docker tag "$image" ${DOCKER_IMAGE_NAME}:latest

echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_ID
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
gcloud --quiet container clusters get-credentials $CLUSTER_NAME

docker push ${DOCKER_IMAGE_NAME}

kubectl config view
kubectl config current-context

kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_DEPLOYMENT_CONTAINER_NAME}=${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT
