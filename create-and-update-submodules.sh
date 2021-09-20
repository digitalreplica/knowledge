#!/usr/bin/env bash

# Bash function to add a repo as a submodule, if it doesn't exist
function add_repo_as_submodule {
  local repo="$1"
  if [ ! -f ".gitmodules" ] || ! grep -q "${repo}" ".gitmodules"
  then
    echo "Adding ${repo}"
    git submodule add "${repo}"
  else
    echo "Updating ${repo}"
  fi

}

# Add all notes repos as submodules for each owner in owners.txt
# - uses the [GitHub CLI](https://cli.github.com/) to get repos
echo "Adding git-notes repos for all owners in owners.txt"
if [ -f owners.txt ]
then
  for owner in `cat owners.txt`
  do
    # The GitHub CLI `repo list` command doesn't return the clone url
    # Instead of making additional API call, add '.git' to the url field
    for repo in `gh repo list ${owner} --public --topic notes --json url --jq '.[]|.url'`
    do
      add_repo_as_submodule "${repo}.git"
    done
  done
fi
echo ""

# Add repos from repos.txt as submodules
echo "Adding git-notes repos from repos.txt"
if [ -f owners.txt ]
then
  for repo in `cat repos.txt`
  do
    add_repo_as_submodule $repo
  done
fi
echo ""

# Update all submodules
echo "Updating all git-notes repos"
git submodule foreach 'git pull'
echo ""

# Complete
echo "Update complete"
