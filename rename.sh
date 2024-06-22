#!/bin/bash

set -e

function err() {
    echo "Error on line $(caller)" >&2
}

trap err ERR

function showHelp() {
cat << EOF  
Usage: ${0} -o <old emails> -n <new email> -d <old names> -c <new name> -u <username> [--repo-names-file=<filename>]

-h, -help,          --help                  Display help
-o,                 --old-email             Comma-separated list of the old email addresses that should be replaced. Case-insensitive.
-n,                 --new-email             New email address to use
-d,                 --old-name              Comma-separated list of the old names that should be replaces. Case-insensitive.
-c,                 --new-name              New name to use
-u,                 --github-username       Your GitHub username.
                    --repo-names-file       A file containing a list of repository names, one per line. Using this option will apply the operation to each repo. If this option is not used, the script will operate on the current directory.
EOF
}

options=$(getopt -l "help,old-email:,new-email:,old-name:,new-name:,github-username:,repo-names-file::" -o "ho:n:d:c:u:" -a -- "$@")

eval set -- "$options"

repo_names_file=""

while true
do
case "$1" in
-h|--help) 
    showHelp
    exit 0
    ;;
-o|--old-email) 
    shift
    old_emails="$1"
    ;;
-n|--new-email)
    shift
    new_email="$1"
    ;;
-d|--old-name)
    shift
    old_names="$1"
    ;;
-c|--new-name)
    shift
    new_name="$1"
    ;;
-u|--github-username)
    shift
    github_username="$1"
    ;;
--repo-names-file)
    shift
    repo_names_file="$1"
    ;;
--)
    shift
    break;;
esac
shift
done

function make_mailmap_file() {
    local mm_file="$(mktemp)"
    IFS=$'\n'
    for old_name in $(echo ${old_names} | tr "," "\n"); do
        for old_email in $(echo ${old_emails} | tr "," "\n"); do
            echo "${new_name} <${new_email}> ${old_name} <${old_email}>" >> "${mm_file}"
        done
    done
    unset IFS
    echo "Created mailmap file: ${mm_file} with contents:" >&2
    cat "${mm_file}" >&2
    echo "${mm_file}"
}

function build_url() {
    local repo_name="$1"
    echo "git@github.com:${github_username}/${repo_name}.git"
}

function run_git_commands() {
    local mailmap_file="$1"
    local github_url="$2"
    local force="$3"
    local branch="$(git branch --list | grep -o '\* .*' | cut -c 3-)"
    git filter-repo ${force} --mailmap "${mailmap_file}"
    git remote add origin "${github_url}"
    git push --set-upstream --force origin "${branch}"
}

mm_file="$(make_mailmap_file)"
if [ -z "${repo_names_file}" ]; then
    repo_url="$(git remote show origin | grep -o "Fetch URL: .*" | cut -c 12-)"
    run_git_commands "${mm_file}" "${repo_url}" "--force"
else
    for repo_name in $(cat "${repo_names_file}"); do
        repo_url="$(build_url "${repo_name}")"
        git clone "${repo_url}"
        pushd "${repo_name}"
        run_git_commands "${mm_file}" "${repo_url}"
        popd
        rm -rf "${repo_name}"
    done
fi

