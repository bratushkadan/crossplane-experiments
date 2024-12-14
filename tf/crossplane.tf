resource "yandex_iam_service_account" "crossplane" {
  name        = "crossplane"
  description = "crossplane service account"
}

resource "yandex_resourcemanager_folder_iam_member" "crossplane-admin" {
  folder_id = local.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.crossplane.id}"
}

resource "yandex_lockbox_secret" "crossplane" {
  name = "crossplane-sa-key"
}

resource "yandex_iam_service_account_key" "crossplane" {
  service_account_id = yandex_iam_service_account.crossplane.id
  description        = "sa key for crossplane sa"

  output_to_lockbox {
    secret_id             = yandex_lockbox_secret.crossplane.id
    entry_for_private_key = "private_key"
  }
}
