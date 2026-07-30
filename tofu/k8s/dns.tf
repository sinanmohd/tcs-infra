locals {
  environments = [
    # "stage", # strictly follows stable git branch, this is our current prod
    "dev",   # strictly follows master git branch
  ]

  # personal dev environment
  environments_pde = [
    "sinan",
    "ditto",
    "adarsh",
    "varun",
    "jithin",
  ]

  # a service can be only removed if it's not required by all the environments
  services = [
    "admin",
    "customer",
    "playground",
    "gateway",
    "app",
    "ask",
    "mcpgateway",
    "notify",
    "api.novu",
    "ws.novu",
    "chat",
    "opensandbox"
  ]

  # place holder domains for new pde services
  # that are not yet merged upstream
  services_pde = [
    "temp",
  ]

  services_standalone = [
    "registry",
    "auth",
    "s3",

    # soon behind vpn
    "signoz",
    "argocd",
  ]

  services_with_envs = toset(concat(
    flatten([
      for env in local.environments : [
        for srv in local.services :
        srv == "" ? "${env}.${var.zone.domain}" : "${srv}.${env}.${var.zone.domain}"
      ]
    ])
    ,
    flatten([
      for env in local.environments_pde : [
        for srv in concat(local.services_pde, local.services) :
        srv == "" ? "${env}.${var.zone.domain}" : "${srv}.${env}.${var.zone.domain}"
      ]
    ]),
    flatten([
      for srv in local.services_standalone : [
        "${srv}.${var.zone.domain}"
      ]
    ]),
  ))

  ingress_IPv4 = toset([
    "138.201.124.169",
    "157.90.141.163",
    "5.9.149.12",
  ])
  ingress_IPv6 = toset([
    "2a01:4f8:172:27ec::1337",
    "2a01:4f8:2220:3819::1337",
    "2a01:4f8:190:3201::1337",
  ])
  ingress_domain = "ingress.k8s.${var.zone.domain}"
}

resource "cloudflare_dns_record" "ingress_ipv4" {
  for_each = local.ingress_IPv4
  zone_id  = var.zone.id
  name     = local.ingress_domain
  ttl      = 3600
  type     = "A"
  content  = each.key
  proxied  = false
}

resource "cloudflare_dns_record" "ingress_ipv6" {
  for_each = local.ingress_IPv6
  zone_id  = var.zone.id
  name     = local.ingress_domain
  ttl      = 3600
  type     = "AAAA"
  content  = each.key
  proxied  = false
}

resource "cloudflare_dns_record" "services" {
  for_each = local.services_with_envs
  zone_id  = var.zone.id
  name     = each.key
  ttl      = 3600
  type     = "CNAME"
  content  = local.ingress_domain
  proxied  = false
}
