#!/usr/bin/env bash
set -e

args_file_as_build_args() {
    local prefix=""
    if [[ "$1" == "docker-flags" ]]; then
        prefix="--build-arg "
        while IFS="=" read -r key value; do
            echo -n "${prefix}$key=\"$value\" "
        done < "args"
    else
        while IFS="=" read -r key value; do
            echo "$key=$value"
        done < "args"
    fi
}

if [[ "$1" == "docker-flags" ]]; then
    args_file_as_build_args $1
else
    args_file_as_build_args
fi
