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

VERSION=v0.13.1

set -o errexit
set -o nounset
set -o pipefail

echo "Installing cert-manager..."
kubectl apply --validate=false -f "https://github.com/jetstack/cert-manager/releases/download/$VERSION/cert-manager.yaml"
echo "Waiting for pods to be ready..."
kubectl wait -n cert-manager --for=condition=Available deploy --all