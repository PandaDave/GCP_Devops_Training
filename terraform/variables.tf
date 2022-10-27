variable "region" {
  default = "us-central1"
  type    = string
}
variable "project_id" {
  default = "mb-devops-user7"
  type    = string
}
variable "infra_bucket" {
  default = "mb-devops-user7-terraform"
  type    = string
}
variable "function_zip" {
  default = "cloudfunction.zip"
  type    = string
}
variable "function_name" {
  default = "pubsub_to_bigquery"
  type    = string
}
variable "project_children" {
  description = "Child projects"
  type = map(object({
    name           = string
    project_number = number
  }))
}
