locals {
  client_to_ip = {
    intel = "100.64.0.17"
    ltim = "100.64.0.8"
    pnap = "125.253.92.137"
  }

  services = [
    "admin",
    "customer",
    "playground",
    "gateway",
    "app",
    "ask",
    "mcpgateway",
    "notify",
    "chat",

    "api.novu",
    "ws.novu",

    "auth",
    "s3",
  ]

  services_with_envs = merge([
    for client in keys(local.client_to_ip) : {
      for srv in local.services :
      "${srv}.${client}.${var.zone.domain}" => "ingress.${client}.${var.zone.domain}"
    }
  ]...)
}

resource "cloudflare_dns_record" "ingress" {
  for_each = local.client_to_ip
  zone_id  = var.zone.id
  name     = "ingress.${each.key}.${var.zone.domain}"
  ttl      = 3600
  type     = "A"
  content  = each.value
  proxied  = false
}

resource "cloudflare_dns_record" "services" {
  for_each = local.services_with_envs
  zone_id  = var.zone.id
  name     = each.key
  ttl      = 3600
  type     = "CNAME"
  content  = each.value
  proxied  = false
}
