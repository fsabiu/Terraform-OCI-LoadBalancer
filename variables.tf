variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_id" {}


variable "load_balancer_id" {
  type = string
  description = "The OCID of the load balancer to associate the backend sets and routing policies with"
}

variable "backend_sets" {
  type = list(object({
    name = string
    policy = string
    health_checker = object({
      protocol = string
      interval_ms = number
      port = number
      retries = number
      return_code = number
      timeout_in_millis = number
      url_path = string
    })
  }))
  description = "The list of backend sets to create and associate with the load balancer"
}

variable "backends" {
  type = list(list(object({
      ip_address = string
      backup = bool
      drain = bool
      offline = bool
      port = number
      weight = number
    })))
}


variable "routing_policies" {
  type = list(object({
    condition_language_version = string
    name = string
    rules = list(object({
      actions = list(object({
        backend_set_name = string
        name = string
      }))
      condition = string
      name = string
    }))
  }))
  description = "The list of routing policies to create and associate with the load balancer"
}


