#!/usr/bin/env bash
<<'###BLOCK-COMMENT'
Updates Readme.md by replacing {git-knowledge-toc} with a
table of comments generated from all submodules.
- reads README-template.md as the source
- uses the [GitHub CLI](https://cli.github.com/) to get repo info
###BLOCK-COMMENT

# Set table of contents template string
TOC='{git-knowledge-toc}'

# Check if template file exists
if [ ! -f README-template.md ]
then
  echo "No README-template.md file. Exiting."
  exit 1
fi

# Extract repo names (owner/repo) from .gitmodules
echo "Getting information for repos"
rm -f .toc.md
for reponame in `grep 'url =' .gitmodules | cut -d '/' -f 4-5 | cut -d '.' -f 1 | sort`
do
  echo $reponame
  repo_description=`gh repo view "${reponame}" --json nameWithOwner,url,description --template "* [{{.nameWithOwner}}]({{.url}}): {{.description}}"`
  echo "${repo_description}" >>.toc.md
done
echo ""

# Merge README-template.md and .toc.md into README.md
echo "Updating README.md"
sed -e "/${TOC}/r .toc.md" -e "/${TOC}/d" README-template.md >README.md
rm -f .toc.md
echo ""

# Complete
echo "Update complete"
