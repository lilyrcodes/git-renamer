# git-renamer
A script to help bulk-renaming of commit authors, for those who have changed their name. 

## Prerequisites
Install [git-filter-repo](https://github.com/newren/git-filter-repo)

## How to use
There are two modes of operation.
1. Oneshot: Copy the script into an existing clone of your repo and run it to update history for that repo only.
2. Multi-repo: Provide the script with a file containing a list of repo names that you want to update. The script will clone, update, and push them for you.

### Usage
```bash
./rename.sh \
  -o <old emails> \
  -n <new email> \
  -d <old names> \
  -c <new name> \
  -u <username> \
  [--repo-names-file=<filename>]
```

|Flag|Description|
|----|-----------|
|-h, --help|Display help|
|-o, --old-email|Comma-separated list of the old email addresses that should be replaced. Case-insensitive.|
|-n, --new-email|New email address to use|
|-d, --old-name|Comma-separated list of the old names that should be replaces. Case-insensitive.|
|-c, --new-name|New name to use|
|-u, --github-username|Your GitHub username.|
|--repo-names-file|(Optional) A file containing a list of repository names, one per line. Using this option will apply the operation to each repo. If this option is not used, the script will operate on the current directory.|
