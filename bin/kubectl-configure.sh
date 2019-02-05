#!/usr/bin/env bash

set -e

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

cd "${project_dir}"

source settings.sh

project_id="$(terraform output project_id)"

gcloud --project "${project_id}" container clusters get-credentials --region "${region}" "${stack_name}"
