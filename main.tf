provider "yandex" {
  token     = var.oauth_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

module "storage_admin" {
  source = "alxrem/service-account/yandex"

  name              = var.storage_admin_name
  roles             = concat(["storage.admin"], var.use_sse ? ["kms.keys.encrypterDecrypter"] : [])
  folder_id         = var.folder_id
  static_access_key = true
}

module "tfstate_operator" {
  source = "alxrem/service-account/yandex"

  name              = var.tfstate_writer_name
  roles             = concat(["ydb.admin"], var.use_sse ? ["kms.keys.encrypterDecrypter"] : [])
  folder_id         = var.folder_id
  static_access_key = true
}

resource "yandex_kms_symmetric_key" "default" {
  count = var.use_sse ? 1 : 0

  name              = var.sse_key_name
  description       = "Managed by terraform"
  default_algorithm = var.sse_key_default_algorithm
  rotation_period   = var.sse_key_rotation_period
  folder_id         = var.folder_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "yandex_storage_bucket" "tfstate" {
  access_key = module.storage_admin.access_key
  secret_key = module.storage_admin.secret_key

  bucket = var.tfstate_bucket

  //noinspection HCLUnknownBlockType
  versioning {
    enabled = var.use_versioning
  }

  //noinspection HCLUnknownBlockType
  dynamic "server_side_encryption_configuration" {
    for_each = var.use_sse ? [1] : []

    content {
      //noinspection HCLUnknownBlockType
      rule {
        //noinspection HCLUnknownBlockType
        apply_server_side_encryption_by_default {
          kms_master_key_id = try(yandex_kms_symmetric_key.default[0].id, null)
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

  grant {
    type        = "CanonicalUser"
    id          = module.tfstate_operator.id
    permissions = ["READ", "WRITE"]
  }
}

resource "yandex_ydb_database_serverless" "tfstate_locks" {
  name        = coalesce(var.tfstate_locks_ydb_name, "${var.tfstate_bucket}-locks")
  description = "Managed by terraform"

  folder_id = var.folder_id
}
