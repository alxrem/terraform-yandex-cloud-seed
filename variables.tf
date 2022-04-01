variable "oauth_token" {
  type = string
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "tfstate_bucket" {
  type = string
}

variable "storage_admin_name" {
  type = string

  default = "storage-admin"
}

variable "tfstate_writer_name" {
  type = string

  default = "tfstate-writer"
}

variable "locks_table_name" {
  type = string

  default = "locks"
}

variable "tfstate_locks_ydb_name" {
  type = string

  default = null
}

variable "use_versioning" {
  type = bool

  default = true
}

variable "use_sse" {
  type = bool

  default = false
}

variable "sse_key_name" {
  type = string

  default = "tfstate-encryption-key"
}

variable "sse_key_default_algorithm" {
  type = string

  default = "AES_128"
}

variable "sse_key_rotation_period" {
  type = string

  default = "8760h"
}
