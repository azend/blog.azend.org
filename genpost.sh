#!/bin/bash

POSTS_FOLDER="./_posts"
ASSETS_FOLDER="./assets"

read -p "Post name: " POST_PRETTY_NAME
read -p "Post categories: " POST_CATEGORIES

# generate post info
POST_DATE="$(date +%Y-%m-%d)"
POST_NAME="$POST_DATE-$(echo $POST_PRETTY_NAME | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')"

POST_FILE="$POSTS_FOLDER/$POST_NAME.md"

# create post file
echo -n "Creating post file '$POST_FILE'..."

cat <<EOF > "$POST_FILE"
---
layout: post
title:  "$POST_PRETTY_NAME"
date:   $POST_DATE 
categories: $POST_CATEGORIES
comments: true
---
Post contents go here.
EOF

echo " [DONE]"

# create asset folder for post
echo -n "Creating assets folder for post..."
mkdir -p "$ASSETS_FOLDER/$POST_NAME"
echo " [DONE]"

# edit post

read -p "Would you like to edit the post? [y/N] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# do dangerous stuff
	$EDITOR $POST_FILE
fi
