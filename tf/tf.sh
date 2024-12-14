#!/usr/bin/env bash

set -e

case $1 in
    init)
        cd $(dirname $0) || exit 1
        shift
        [[ -f ".terraform.lock.hcl" ]] && rm .terraform.lock.hcl
        terraform providers lock \
            -net-mirror=https://terraform-mirror.yandexcloud.net \
            -platform=darwin_arm64 \
            -platform=linux_amd64 \
            -platform=linux_arm64 \
            yandex-cloud/yandex
        TF_SECRET_KEY=$(yc --profile cloud-danilabratushka lockbox payload get e6qvdsedr18e80457nva | yq '.entries | .[] | select (.key == "sa-secret-key") | .text_value')
        terraform init -backend-config="secret_key=${TF_SECRET_KEY}" $@
        ;;
    *)
        YC_TOKEN=$(yc --profile cloud-danilabratushka iam create-token) terraform $@
        ;;
esac

