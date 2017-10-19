#!/bin/bash

bash_escape() ( printf '\\033[%dm' $1; );
RESET=$(bash_escape 0); BLUE=$(bash_escape 34);
put_info() ( printf "${BLUE}[INFO]${RESET} $1\n");

put_info "Authenticating to DockerHub";
docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD";

put_info "Building new image";
docker build .;

image=$(docker images --format="{{.ID}}" | head -n 1);

put_info "Tagging image '$image' as '$TRAVIS_COMMIT'";
docker tag "$image" ${DOCKER_IMAGE_NAME}:${MODULE_VERSION};
put_info "Tagging image '$image' as 'latest'";
docker tag "$image" ${DOCKER_IMAGE_NAME}:latest;

put_info "Pushing image to DockerHub";
docker push ${DOCKER_IMAGE_NAME};

put_info "Pulling new image into container '${KUBE_DEPLOYMENT_CONTAINER_NAME}' on deployment '${KUBE_DEPLOYMENT_NAME}'";
kubectl config view;
kubectl config current-context;
kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_DEPLOYMENT_CONTAINER_NAME}=${DOCKER_IMAGE_NAME}:${MODULE_VERSION};

# variables needed for Okapi registration
service_id="${FOLIO_MODULE_NAME}-${MODULE_VERSION}"
service_url="http://${KUBE_DEPLOYMENT_NAME}:8081"
okapi_modules_endpoint="${OKAPI_EXTERNAL_ADDRESS}/_/proxy/modules"
okapi_discovery_endpoint="${OKAPI_EXTERNAL_ADDRESS}/_/discovery/modules"
okapi_tenants_modules_endpoint="${OKAPI_EXTERNAL_ADDRESS}/_/proxy/tenants/${FOLIO_TENANT_ID}/modules"
okapi_tenant_install_endpoint="${OKAPI_EXTERNAL_ADDRESS}/_/proxy/tenants/${FOLIO_TENANT_ID}/install"

# deselect module from the tenant
get_selected_modules() {
  curl -s -X GET $okapi_tenants_modules_endpoint | \
  jq -c "map(select(.id | test(\"${FOLIO_MODULE_NAME}-.*\")==true)) | .[]";
}
delete_selected_modules() {
  while read object; do
    id=$(echo $object | jq -r '.id')
    put_info "Deselecting module ${id} from tenant ${FOLIO_TENANT_ID}";
    curl -s -X DELETE "${okapi_tenants_modules_endpoint}/${id}";
  done;
}
get_selected_modules | delete_selected_modules;

# delete existing discovery records for module
get_discovered_modules() {
  curl -s -X GET $okapi_discovery_endpoint | \
  jq -c "map(select(.srvcId | test(\"${FOLIO_MODULE_NAME}-.*\")==true)) | .[]";
}
delete_discovered_modules() {
  while read object; do
    srvcId=$(echo $object | jq -r '.srvcId');
    instId=$(echo $object | jq -r '.instId');
    put_info "Deleting existing discovery record with Service ID: ${srvcId} and Instance ID: ${instId}";
    curl -s -X DELETE "${okapi_discovery_endpoint}/${srvcId}/${instId}";
  done;
}
get_discovered_modules | delete_discovered_modules;

# delete existing module registrations
get_registered_modules() {
  curl -s -X GET $okapi_modules_endpoint | \
  jq -c "map(select(.id | test(\"${FOLIO_MODULE_NAME}-.*\")==true)) | .[]";
}
delete_registered_modules() {
  while read object; do
    id=$(echo $object | jq -r '.id')
    put_info "Deleting existing module registration with Service ID: ${id}";
    curl -s -X DELETE "${okapi_modules_endpoint}/${id}";
  done;
}
get_registered_modules | delete_registered_modules;

# register module
put_info "Registering module to Okapi with Service ID: ${service_id}";
cat ModuleDescriptor.json | jq ".id = \"${service_id}\"" | curl -s -X POST -d @- $okapi_modules_endpoint;

# create discovery record
discovery_payload() {
  cat <<EOF
{
  "srvcId": "${service_id}",
  "instId": "${service_id}",
  "url": "${service_url}"
}
EOF
}

put_info "Creating discovery record for module with Service ID: ${service_id} and Instance ID: ${service_id}";
echo "$(discovery_payload)" | curl -s -X POST -d @- $okapi_discovery_endpoint;

# select for tenant
module_tenant_payload() {
  cat <<EOF
[
  {
    "id": "${service_id}",
    "action": "enable"
  }
]
EOF
}

put_info "Link ${service_id} to tenant ${FOLIO_TENANT_ID}";
echo "$(module_tenant_payload)" | curl -s -X POST -d @- $okapi_tenant_install_endpoint;
