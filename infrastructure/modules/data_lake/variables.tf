variable "name_prefix" {
  type = string
}
variable "account_id" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "force_destroy" {
  type    = bool
  default = false
}

