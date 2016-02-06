#!/bin/bash

jekyll build

rsync -avz --progress --delete -e ssh _site/ azendorg@azend.org:~/public_html/blog-azend-org/

