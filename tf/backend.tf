terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "b1gtf4tsi5mttbuirmbv-tf-state"
    key        = "crossplane-experiments.tfstate"
    region     = "us-east-1"
    access_key = "YCAJER747GHly8xA9Cj5p2e8W"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}
