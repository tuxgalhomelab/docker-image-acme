#!/usr/bin/env bash

set -e -o pipefail

script_parent_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
git_repo_dir="$(realpath "${script_parent_dir:?}/..")"

ARGS_FILE="${git_repo_dir:?}/config/ARGS"

git_repo_get_all_tags() {
    git_repo="${1:?}"
    git -c 'versionsort.suffix=-' ls-remote \
        --exit-code \
        --refs \
        --sort='version:refname' \
        --tags \
        ${git_repo:?} '*.*.*' | \
        cut --delimiter='/' --fields=3
}

git_repo_latest_tag() {
    git_repo="${1:?}"
    # Strip out any strings that begin with 'v' before identifying the highest semantic version.
    highest_sem_ver_tag=$(git_repo_get_all_tags ${git_repo:?} | sed -E s'#^v(.*)$#\1#g' | sed '/-/!{s/$/_/}' | sort --version-sort | sed 's/_$//'| tail -1)
    # Identify the correct tag for the semantic version of interest.
    git_repo_get_all_tags ${git_repo:?} | grep "${highest_sem_ver_tag:?}$" | cut --delimiter='/' --fields=3
}

set_config_arg() {
    arg="${1:?}"
    val="${2:?}"
    sed -i -E "s/^${arg:?}=(.*)\$/${arg:?}=${val:?}/" ${ARGS_FILE:?}
}

update_latest_upstream_version() {
    git_repo="${1:?}"
    upstream_config_key="${2:?}"
    ver=$(git_repo_latest_tag ${git_repo:?})
    echo "Updating ${upstream_config_key:?} -> ${ver:?}"
    set_config_arg "${upstream_config_key:?}" "${ver:?}"
}

repo_url="https://github.com/acmesh-official/acme.sh.git"
config_key="ACME_VERSION"

update_latest_upstream_version "${repo_url:?}" "${config_key:?}"
