#!/bin/sh

INFRA_WORKDIR=$1
touch $INFRA_WORKDIR/backend.tf

cat <<EOF >$INFRA_WORKDIR/backend.tf
terraform {
  backend "s3" {
    key    = "$TF_VAR_KEY"
    region = "$TF_VAR_REGION"
    bucket = "$TF_VAR_BUCKET_NAME"
  }
}
EOF