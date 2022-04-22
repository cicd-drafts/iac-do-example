variable "node_type" {
  type    = string
  default = "s-1vcpu-2gb"
}

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "node_count" {
  default = 1
}
