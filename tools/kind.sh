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

# This script constructs a 'content/' directory that contains content for all
# configured versions of the documentation.

set -o errexit
set -o nounset
set -o pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
VERSION="v0.7.0"

source "${REPO_ROOT}/tools/lib.sh"

kind="${REPO_ROOT}/tools/bin/kind"
mkdir -p "$(dirname "$kind")"

if ! command -v curl &>/dev/null; then
    echo "Ensure curl command is installed"
    exit 1
fi

if ! test -f "${kind}"; then
    echo "+++ Fetching kind binary and saving to ${kind}"
    detect_and_set_goos_goarch

    if [ "$GOOS" = "darwin" ]; then
        curl -sSLo "${kind}" "https://github.com/kubernetes-sigs/kind/releases/download/${VERSION}/kind-darwin-amd64"
        check_sha "${kind}" "11b8a7fda7c9d6230f0f28ffe57831a7227c0655dfb8d38e838e8f03db6612de"
    elif [ "$GOOS" = "linux" ]; then
        curl -sSLo "${kind}" "https://github.com/kubernetes-sigs/kind/releases/download/${VERSION}/kind-linux-amd64"
        check_sha "${kind}" "0e07d5a9d5b8bf410a1ad8a7c8c9c2ea2a4b19eda50f1c629f1afadb7c80fae7"
    else
    	echo "Unsupported OS: $GOOS"
    	exit 1
    fi
    chmod +x "${kind}"
fi

"${kind}" "$@"
