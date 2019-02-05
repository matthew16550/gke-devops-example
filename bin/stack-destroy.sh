#!/usr/bin/env bash

set -e

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

cd "${project_dir}"

source settings.sh

terraform destroy terraform
