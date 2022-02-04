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

packages_to_install() {
    while IFS="=" read -r key value; do
        echo -n "$key=$value "
    done < "packages-to-install"
}

if [[ "$1" == "docker-flags" ]]; then
    args_file_as_build_args $1
    echo -n "--build-arg PACKAGES_TO_INSTALL=\"$(packages_to_install)\" "
else
    args_file_as_build_args
    echo "PACKAGES_TO_INSTALL=$(packages_to_install)"
fi
