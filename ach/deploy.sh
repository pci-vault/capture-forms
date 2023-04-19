#!/bin/bash
set -e

cd "$(dirname "$0")" || exit

stage=${1:-"dev"}

if [ "$stage" != "prod" ]; then
  export pci_address="https://api-$stage.pcivault.io"
fi

npm run build

export AWS_PROFILE=pcivault
aws s3 cp public/build/ach_form.js s3://pvs-frontend/"$stage"/ach/ --acl public-read
aws s3 cp public/build/ach_form.css s3://pvs-frontend/"$stage"/ach/ --acl public-read
aws s3 cp public/how-to.html s3://pvs-frontend/"$stage"/ach/how-to-capture-and-tokenize-us-bank-account-data.html --acl public-read
aws s3 cp public/high-summit.regular.ttf s3://pvs-frontend/"$stage"/ach/ --acl public-read
aws s3 cp public/SFProDisplay-Bold.woff2 s3://pvs-frontend/"$stage"/ach/ --acl public-read
aws s3 cp public/SFProDisplay-Light.woff2 s3://pvs-frontend/"$stage"/ach/ --acl public-read
aws s3 cp public/SFProDisplay-Medium.woff2 s3://pvs-frontend/"$stage"/ach/ --acl public-read
aws s3 cp public/SFProDisplay-Regular.woff2 s3://pvs-frontend/"$stage"/ach/ --acl public-read
aws s3 cp public/logo.webp s3://pvs-frontend/"$stage"/ach/ --acl public-read
