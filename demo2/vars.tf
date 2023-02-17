variable "user" {
  type = map(string)
}

variable "vrf" {
  type = string
}

variable "bridge_domains" {
  type = map(object({
    name    = string
    gateway = string
  }))
}

variable "filters" {
  type = map(object({
    name    = string
    dest    = string
    ether_t = string
    prot    = string
  }))
}

variable "contracts" {
  type = map(object({
    contract = string
    subject  = string
  }))
}

variable "ap" {
  type = string
}

variable "epgs" {
  type = map(object({
    name = string
    bd   = string
    contracts = map(object({
      name = string
      type = string
    }))
  }))
}
