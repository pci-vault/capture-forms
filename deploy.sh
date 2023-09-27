#!/bin/bash
set -e

cd "$(dirname "$0")" || exit

stage=${1:-"dev"}

if [ "$stage" != "prod" ]; then
  export pci_address="https://api-$stage.pcivault.io"
fi

npm run build

export AWS_PROFILE=pcivault

echo "--- UPLOADING PCD FORM ---"
aws s3 cp public/build/pcd_form.js s3://pvs-frontend/"$stage"/pcd/ --acl public-read
aws s3 cp public/build/pcd_form.css s3://pvs-frontend/"$stage"/pcd/ --acl public-read

echo "--- UPLOADING ACH FORM ---"
aws s3 cp public/build/ach_form.js s3://pvs-frontend/"$stage"/ach/ --acl public-read
aws s3 cp public/build/ach_form.css s3://pvs-frontend/"$stage"/ach/ --acl public-read

echo "--- UPLOADING SHARED ASSETS ---"
aws s3 cp public/assets/card.svg s3://pvs-frontend/"$stage"/assets/ --acl public-read
aws s3 cp public/assets/high-summit.regular.ttf s3://pvs-frontend/"$stage"/assets/ --acl public-read
aws s3 cp public/assets/SFProDisplay-Bold.woff2 s3://pvs-frontend/"$stage"/assets/ --acl public-read
aws s3 cp public/assets/SFProDisplay-Light.woff2 s3://pvs-frontend/"$stage"/assets/ --acl public-read
aws s3 cp public/assets/SFProDisplay-Medium.woff2 s3://pvs-frontend/"$stage"/assets/ --acl public-read
aws s3 cp public/assets/SFProDisplay-Regular.woff2 s3://pvs-frontend/"$stage"/assets/ --acl public-read
aws s3 cp public/assets/logo.webp s3://pvs-frontend/"$stage"/assets/ --acl public-read
aws s3 cp public/assets/chip.svg s3://pvs-frontend/"$stage"/assets/ --acl public-read

for file in public/assets/card-icons/*
do
  aws s3 cp "$file" s3://pvs-frontend/"$stage"/assets/card-icons/ --acl public-read
done
