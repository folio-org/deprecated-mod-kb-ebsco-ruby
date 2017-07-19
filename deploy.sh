#!/bin/bash

set -e

bash_escape() ( printf '\\033[%dm' $1; );
RESET=$(bash_escape 0); BLUE=$(bash_escape 34);
put_info() ( printf "${BLUE}[INFO]${RESET} $1\n");

put_info "Authenticating to DockerHub";
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD";

put_info "Building new image";
docker build .;

image=$(docker images --format="{{.ID}}" | head -n 1);

put_info "Tagging image '$image' as '$TRAVIS_COMMIT'";
docker tag "$image" ${DOCKER_IMAGE_NAME}:${TRAVIS_COMMIT};
put_info "Tagging image '$image' as 'latest'";
docker tag "$image" ${DOCKER_IMAGE_NAME}:latest;

put_info "Authenticating to Google Cloud Services";
echo $GCLOUD_SERVICE_KEY | base64 --decode -i > ${HOME}/gcloud-service-key.json;
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json;

put_info "Configuring Google Cloud Services";
gcloud --quiet config set project $PROJECT_ID;
gcloud --quiet config set container/cluster $CLUSTER_NAME;
gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE};
gcloud --quiet container clusters get-credentials $CLUSTER_NAME;

put_info "Pushing image to DockerHub";
docker push ${DOCKER_IMAGE_NAME};

put_info "Pulling new image into container '${KUBE_DEPLOYMENT_CONTAINER_NAME}' on deployment '${KUBE_DEPLOYMENT_NAME}'";
kubectl config view;
kubectl config current-context;
kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_DEPLOYMENT_CONTAINER_NAME}=${DOCKER_IMAGE_NAME}:${TRAVIS_COMMIT};
