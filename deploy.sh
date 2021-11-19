#!/bin/sh
rm -rf public
hugo

dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
echo "dir: $dir"

ssh_host="g22"
rsync --iconv=UTF-8-MAC,UTF-8 -avzc --delete --exclude-from=rsync-exclude ${dir}/public/ ${ssh_host}:/var/www/html