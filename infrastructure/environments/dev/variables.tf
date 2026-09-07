variable "aws_region" {
  type    = string
  default = "eu-west-1"
}
variable "aws_profile" {
  type    = string
  default = "default"
}
variable "project_name" {
  type    = string
  default = "smartgrid-ai"
}
variable "environment" {
  type    = string
  default = "dev"
}
variable "anomaly_threshold_kw" {
  type    = number
  default = 80
}
variable "monthly_budget_usd" {
  type    = number
  default = 10
}
variable "budget_notification_email" {
  type        = string
  default     = ""
  description = "Optional email for AWS Budget alerts. Empty disables budget creation."
}
