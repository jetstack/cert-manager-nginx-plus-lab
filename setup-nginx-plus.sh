#!/usr/bin/env bash
# Copyright 2020 The Jetstack cert-manager contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")" && pwd)}"

source "${REPO_ROOT}/tools/lib.sh"

sudo apt-get update
sudo apt-get install -y build-essential


TMP_DIR=`mktemp -d`
# check if tmp dir was created
if [[ ! "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

git clone https://github.com/nginxinc/kubernetes-ingress/ "$TMP_DIR"
cd "$TMP_DIR"
git checkout v1.6.2

cp "$REPO_ROOT/nginx-repo.crt" ./
cp "$REPO_ROOT/nginx-repo.key" ./

make clean
make container DOCKERFILE=DockerfileForPlus PREFIX=demo.cert-manager.io/nginx-plus-ingress

tool kind load docker-image demo.cert-manager.io/nginx-plus-ingress:1.6.2

sed -i "s/nginx-plus-ingress:1.6.2/demo.cert-manager.io\/nginx-plus-ingress:1.6.2/g" deployments/daemon-set/nginx-plus-ingress.yaml
kubectl apply -f deployments/common/ns-and-sa.yaml
kubectl apply -f deployments/rbac/rbac.yaml
kubectl apply -f deployments/common/default-server-secret.yaml
kubectl apply -f deployments/common/nginx-config.yaml
kubectl apply -f deployments/common/custom-resource-definitions.yaml
kubectl apply -f deployments/daemon-set/nginx-plus-ingress.yaml
kubectl apply -f deployments/service/nodeport.yaml

# Expose the dashboard
kubectl patch ds nginx-ingress -n nginx-ingress --type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "-nginx-status-allow-cidrs=0.0.0.0/0" }]'
kubectl patch ds nginx-ingress -n nginx-ingress --type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/ports/-", "value": {"containerPort": 8080, "hostPort": 8080}}]'
cd "${REPO_ROOT}"
kubectl apply -f  nginx-plus-dashboard.yaml

echo "Waiting for pods to be ready"
kubectl rollout status ds/nginx-ingress -n nginx-ingress