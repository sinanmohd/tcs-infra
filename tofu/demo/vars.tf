variable "zone" {
  default = {
    id = "031154e33fd9ee30954f8dcfc8429975"
    # just id is needed, this is to work around a provider bug,
    # avoid changes on every apply eg: admin.dev.bud.studio -> admin.dev
    domain = "bud-demo.com"
  }
}
