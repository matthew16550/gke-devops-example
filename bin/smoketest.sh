#!/usr/bin/env bash

set -e

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

cd "${project_dir}"

hello_url="$(terraform output hello_url)"

response="$(curl -f --progress-bar "${hello_url}")"

if grep -q "Hello World" <<< "${response}"; then
  echo "OK"
else
  echo "Bad response:"
  echo "${response}"
  exit 1
fi
