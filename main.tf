provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

resource "oci_load_balancer_backend_set" "backend_set" {
  for_each = { for bs in var.backend_sets : bs.name => bs }

  load_balancer_id = var.load_balancer_id
  name             = each.value.name
  policy           = each.value.policy

  health_checker {
    interval_ms = each.value.health_checker.interval_ms
    port               = each.value.health_checker.port
    protocol           = each.value.health_checker.protocol
    retries            = each.value.health_checker.retries
    return_code        = each.value.health_checker.return_code
    timeout_in_millis  = each.value.health_checker.timeout_in_millis
    url_path           = each.value.health_checker.url_path
  }
}

locals {
  backends = flatten([
    for idx, backend_set in var.backend_sets : [
      for i, backend in var.backends[idx] : {
        load_balancer_id = var.load_balancer_id
        backendset_name  = backend_set.name
        ip_address       = backend.ip_address
        port             = backend.port
        backup           = backend.backup
        drain            = backend.drain
        offline          = backend.offline
        weight           = backend.weight
      }
    ]
  ])
}

resource "oci_load_balancer_backend" "backend" {
  for_each = { for i, backend in local.backends : i => backend }

  load_balancer_id = each.value.load_balancer_id
  backendset_name  = each.value.backendset_name
  ip_address       = each.value.ip_address
  port             = each.value.port
  backup           = each.value.backup
  drain            = each.value.drain
  offline          = each.value.offline
  weight           = each.value.weight

  depends_on = [
    oci_load_balancer_backend_set.backend_set
  ]
}


resource "oci_load_balancer_load_balancer_routing_policy" "routing_policy" {
  for_each = { for rp in var.routing_policies : rp.name => rp }

  load_balancer_id          = var.load_balancer_id
  condition_language_version = each.value.condition_language_version
  name                      = each.value.name

  dynamic "rules" {
    for_each = each.value.rules
    content {
      condition = rules.value.condition
      name      = rules.value.name

      dynamic "actions" {
        for_each = rules.value.actions
        content {
          backend_set_name = actions.value.backend_set_name
          name             = actions.value.name
        }
      }
    }
  }

  depends_on = [
    oci_load_balancer_backend_set.backend_set
  ]

}