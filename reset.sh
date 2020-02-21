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

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")" && pwd)}"

source "${REPO_ROOT}/tools/lib.sh"

# We do want to continue on a fail here
set +o errexit

tool kind delete cluster
sudo rm /usr/local/bin/kubectl
sudo rm -fr /tmp/cert-manager-venafi-demo
rm "${REPO_ROOT}/tools/bin/kind"
