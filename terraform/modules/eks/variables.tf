variable "name" {}
variable "role_arn" {}
variable "subnets" {
  type = list(string)
}
variable "sg_id" {}
