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
VERSION="v0.8.1"

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
        check_sha "${kind}" "cdd8dfe7dff764429badcd636179b0e3eb937640cfe56749dd9b8f9c048cb7db"
    elif [ "$GOOS" = "linux" ]; then
        curl -sSLo "${kind}" "https://github.com/kubernetes-sigs/kind/releases/download/${VERSION}/kind-linux-amd64"
        check_sha "${kind}" "781c3db479b805d161b7c2c7a31896d1a504b583ebfcce8fcd49538c684d96bc"
    else
    	echo "Unsupported OS: $GOOS"
    	exit 1
    fi
    chmod +x "${kind}"
fi

"${kind}" "$@"
