#!/bin/bash
set -e

cd "$(dirname "$0")" || exit

file=$1
alg=$2

# calculate a digest using the algorith e.g. sha384
cat $file | openssl dgst -$alg -binary | openssl base64 -A
