#!/usr/bin/env bash

set -e

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

cd "${project_dir}"

hello_image="$(terraform output hello_image)"

docker push "${hello_image}"
