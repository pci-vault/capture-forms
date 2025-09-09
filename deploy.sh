#!/bin/bash
set -e

cd "$(dirname "$0")" || exit

stage=${1:-"dev"}
hashing_alg=sha384
timestamp=$(date +%s)

if [ "$stage" != "prod" ]; then
  export pci_address="https://api-$stage.pcivault.io"
fi

npm run build

echo "--- CLEAR SRI HASHES ---"
echo "Deleting [form:hash][pcd:js]"
aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:js\"}}"
echo "Deleting [form:hash][pcd:css]"
aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:css\"}}"
echo "Deleting [form:hash][ach:js]"
aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"ach:js\"}}"
echo "Deleting [form:hash][pcd:js]"
aws dynamodb delete-item --table-name pci_vault_serverless_"$stage" --key "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:js\"}}"

echo "--- UPLOADING PCD FORM ---"
aws s3 cp public/build/pcd_form.js s3://pvs-frontend/"$stage"/pcd/ --acl public-read
aws s3 cp public/build/pcd_form.css s3://pvs-frontend/"$stage"/pcd/ --acl public-read

echo "--- CALCULATING SRI HASH FOR PCD FORM ---"
hash=$(./hash.sh public/build/pcd_form.js $hashing_alg)
echo "Setting [form:hash][pcd:js] to" $hash
aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:js\"}, \"type\": {\"S\": \"js\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"
hash=$(./hash.sh public/build/pcd_form.css $hashing_alg)
echo "Setting [form:hash][pcd:css] to" $hash
aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"pcd:css\"}, \"type\": {\"S\": \"css\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"

echo "--- UPLOADING ACH FORM ---"
aws s3 cp public/build/ach_form.js s3://pvs-frontend/"$stage"/ach/ --acl public-read
aws s3 cp public/build/ach_form.css s3://pvs-frontend/"$stage"/ach/ --acl public-read

echo "--- CALCULATING SRI HASH FOR ACH FORM ---"
hash=$(./hash.sh public/build/ach_form.js $hashing_alg)
echo "Setting [form:hash][ach:js] to" $hash
aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"ach:js\"}, \"type\": {\"S\": \"js\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"
hash=$(./hash.sh public/build/pcd_form.css $hashing_alg)
echo "Setting [form:hash][ach:css] to" $hash
aws dynamodb put-item --table-name pci_vault_serverless_"$stage" --item "{\"pci_pk\": {\"S\":\"form:hash\"}, \"pci_sk\": {\"S\": \"ach:css\"}, \"type\": {\"S\": \"css\"}, \"alg\": {\"S\": \"$hashing_alg\"}, \"value\": {\"S\": \"$hash\"}, \"updated_at\": {\"N\": \"$timestamp\"}}"

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
