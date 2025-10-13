#!/bin/bash
set -e

cd "$(dirname "$0")" || exit

stage=${1:-"dev"}
version=${2:-""}
update_latest=${3:-"y"}
hashing_alg=sha384
timestamp=$(date +%s)

if [ "$version" == "" ]; then
  version=$(git describe --always --tag)
fi

if [ "$stage" != "prod" ]; then
  export pci_address="https://api-$stage.pcivault.io"
fi

npm run build

echo "--- CLEAR SRI HASHES for version $version ---"
echo "Deleting [form:hash][pcd:js:$version]"
aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:js:$version\"}}"
echo "Deleting [form:hash][pcd:css:$version]"
aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:css:$version\"}}"
echo "Deleting [form:hash][ach:js:$version]"
aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"ach:js:$version\"}}"
echo "Deleting [form:hash][pcd:js:$version]"
aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:js:$version\"}}"

echo "--- UPLOADING PCD FORM for version $version ---"
aws s3 cp public/build/pcd_form.js s3://pvs-frontend/"$stage"/pcd/"$version"/ --acl public-read
aws s3 cp public/build/pcd_form.css s3://pvs-frontend/"$stage"/pcd/"$version"/ --acl public-read

echo "--- CALCULATING SRI HASH FOR PCD FORM version $version ---"
hash=$(./hash.sh public/build/pcd_form.js $hashing_alg)
echo "Setting [form:hash][pcd:js:$version] to" $hash
aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:js:$version\"}, \"type\": {\"S\": \"js\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"
hash=$(./hash.sh public/build/pcd_form.css $hashing_alg)
echo "Setting [form:hash][pcd:css:$version] to" $hash
aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:css:$version\"}, \"type\": {\"S\": \"css\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"

echo "--- UPLOADING ACH FORM for version $version ---"
aws s3 cp public/build/ach_form.js s3://pvs-frontend/"$stage"/ach/"$version"/ --acl public-read
aws s3 cp public/build/ach_form.css s3://pvs-frontend/"$stage"/ach/"$version"/ --acl public-read

echo "--- CALCULATING SRI HASH FOR ACH FORM version $version ---"
hash=$(./hash.sh public/build/ach_form.js $hashing_alg)
echo "Setting [form:hash][ach:js:$version] to" $hash
aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"ach:js:$version\"}, \"type\": {\"S\": \"js\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"
hash=$(./hash.sh public/build/pcd_form.css $hashing_alg)
echo "Setting [form:hash][ach:css:$version] to" $hash
aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"ach:css:$version\"}, \"type\": {\"S\": \"css\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"

if [ "$update_latest" == "y" ]; then
  echo "--- CLEAR SRI HASHES for version LATEST ---"
  echo "Deleting [form:hash][pcd:js:LATEST]"
  aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:js:LATEST\"}}"
  echo "Deleting [form:hash][pcd:css:LATEST]"
  aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:css:LATEST\"}}"
  echo "Deleting [form:hash][ach:js:LATEST]"
  aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"ach:js:LATEST\"}}"
  echo "Deleting [form:hash][pcd:js:LATEST]"
  aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:js:LATEST\"}}"

  echo "--- UPLOADING PCD FORM for version LATEST ---"
  aws s3 cp public/build/pcd_form.js s3://pvs-frontend/"$stage"/pcd/LATEST/ --acl public-read
  aws s3 cp public/build/pcd_form.css s3://pvs-frontend/"$stage"/pcd/LATEST/ --acl public-read

  echo "--- CALCULATING SRI HASH FOR PCD FORM version LATEST ---"
  hash=$(./hash.sh public/build/pcd_form.js $hashing_alg)
  echo "Setting [form:hash][pcd:js:LATEST] to" $hash
  aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:js:LATEST\"}, \"type\": {\"S\": \"js\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"

  hash=$(./hash.sh public/build/pcd_form.css $hashing_alg)
  echo "Setting [form:hash][pcd:css:LATEST] to" $hash
  aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:css:LATEST\"}, \"type\": {\"S\": \"css\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"

  echo "--- UPLOADING ACH FORM for version LATEST ---"
  aws s3 cp public/build/ach_form.js s3://pvs-frontend/"$stage"/ach/LATEST/ --acl public-read
  aws s3 cp public/build/ach_form.css s3://pvs-frontend/"$stage"/ach/LATEST/ --acl public-read

  echo "--- CALCULATING SRI HASH FOR ACH FORM version LATEST ---"
  hash=$(./hash.sh public/build/ach_form.js $hashing_alg)
  echo "Setting [form:hash][ach:js:LATEST] to" $hash
  aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"ach:js:LATEST\"}, \"type\": {\"S\": \"js\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"
  hash=$(./hash.sh public/build/pcd_form.css $hashing_alg)
  echo "Setting [form:hash][ach:css:LATEST] to" $hash
  aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"ach:css:LATEST\"}, \"type\": {\"S\": \"css\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"
fi

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
