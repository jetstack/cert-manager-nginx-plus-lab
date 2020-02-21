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

VERSION="v1.17.0"
REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")" && pwd)}"

source "${REPO_ROOT}/tools/lib.sh"

curl https://get.docker.com | sudo bash
sudo setfacl -m "user:$USER:rw" /var/run/docker.sock

tool kind create cluster --image "kindest/node:$VERSION" --config ./cluster.yaml

sudo cp "${REPO_ROOT}/tools/kubectl.sh" /usr/local/bin/kubectl
sudo chmod +x /usr/local/bin/kubectl