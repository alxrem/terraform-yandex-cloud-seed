output "storage_admin_access_key" {
  value = module.storage_admin.access_key
}

output "storage_admin_secret_key" {
  value = module.storage_admin.secret_key

  sensitive = true
}

//noinspection HILUnresolvedReference
output "terraform_backend" {
  value = <<-EOF
  terraform {
    backend "s3" {
      endpoint                    = "storage.yandexcloud.net"
      bucket                      = "${yandex_storage_bucket.tfstate.bucket}"
      region                      = "us-east-1"
      # key                       = ".tfstate"
      skip_region_validation      = true
      skip_credentials_validation = true
      dynamodb_table              = "${var.locks_table_name}"
    }
  }
  EOF
}

//noinspection HILUnresolvedReference
output "terraform_init" {
  value = <<-EOF
  terraform init -backend-config=access_key=${module.tfstate_operator.access_key} -backend-config=secret_key=${module.tfstate_operator.secret_key} -backend-config=dynamodb_endpoint=${yandex_ydb_database_serverless.tfstate_locks.document_api_endpoint}
  EOF

  sensitive = true
}

//noinspection HILUnresolvedReference
output "terragrunt_remote_state" {
  value = <<-EOF
  remote_state {
    backend = "s3"
    config  = {
      endpoint                    = "https://storage.yandexcloud.net"
      bucket                      = "${yandex_storage_bucket.tfstate.bucket}"
      region                      = "us-east-1"
      # key                         = ".tfstate"
      # shared_credentials_file     = ".credentials"
      skip_credentials_validation = true
      dynamodb_endpoint           = "${yandex_ydb_database_serverless.tfstate_locks.document_api_endpoint}"
      dynamodb_table              = "${var.locks_table_name}"
    }
  }
  EOF

  sensitive = true
}

output "shared_credentials_file" {
  value = <<-EOF
  [default]
  aws_access_key_id = ${module.tfstate_operator.access_key}
  aws_secret_access_key = ${module.tfstate_operator.secret_key}
  EOF

  sensitive = true
}
