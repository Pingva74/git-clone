#!/bin/bash
# VARS
G_TOKEN="INSERT_TOKEN_HERE"
G_URL=""
G_DIR=""
G_FILE=""

#MAIN
# get projects list to file
curl --silent --header "PRIVATE-TOKEN:$G_TOKEN" "https://git.com/api/v4/projects" | jq -c '.[].id' > projects.tmp
curl --silent --header "PRIVATE-TOKEN:$G_TOKEN" "https://git.com/api/v4/projects" | jq -c '.[].ssh_url_to_repo' > url.list.tmp
cat url.list.tmp | sed 's/"//'|sed 's/"$//' > repo.list.tmp

#clone and tar dirs
while read G_URL
do
git clone $G_URL
echo $G_URL
G_DIR=$(ls -d */)
G_FILE=$(echo $G_DIR | rev | cut -c 2- | rev)
tar -czpf $G_FILE.tar.gz ./$G_DIR
rm -rf ./$G_DIR
done < repo.list.tmp

#Copy dirs to google drive
ls -l | grep .tar.gz | awk -F " " '{print $9}' > files.tmp
while read G_FILE
do
  rclone copy $G_FILE google-drive:git
  rm -f $G_FILE
done < files.tmp
rm -f ./*.tmp
