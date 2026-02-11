variable "cluster_name" {}
variable "node_role_arn" {}
variable "subnets" {
  type = list(string)
}
