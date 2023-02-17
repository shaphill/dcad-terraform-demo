terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
    }
  }
}

provider "aci" {
  username = var.user.username
  password = var.user.password
  url      = var.user.url
  insecure = true
}

resource "aci_tenant" "tenant" {
  name = "demo_tenant"
}

resource "aci_vrf" "vrf" {
  tenant_dn = aci_tenant.tenant.id
  name      = var.vrf
}

resource "aci_bridge_domain" "bridge_domains" {
  for_each = var.bridge_domains

  tenant_dn          = aci_tenant.tenant.id
  name               = each.value.name
  relation_fv_rs_ctx = aci_vrf.vrf.id
}

resource "aci_subnet" "subnets" {
  for_each = var.bridge_domains

  parent_dn = aci_bridge_domain.bridge_domains[each.key].id
  ip        = each.value.gateway
}

resource "aci_filter" "filters" {
  for_each = var.filters

  name      = each.value.name
  tenant_dn = aci_tenant.tenant.id
}

resource "aci_filter_entry" "filter_entries" {
  for_each = var.filters

  filter_dn   = aci_filter.filters[each.key].id
  name        = each.value.name
  d_from_port = each.value.dest
  d_to_port   = each.value.dest
  ether_t     = each.value.ether_t
  prot        = each.value.prot
}

resource "aci_contract" "contracts" {
  for_each = var.contracts

  tenant_dn = aci_tenant.tenant.id
  name      = each.value.contract
}

resource "aci_contract_subject" "contract_subjects" {
  for_each = var.contracts

  contract_dn                  = aci_contract.contracts[each.key].id
  name                         = each.value.subject
  relation_vz_rs_subj_filt_att = [aci_filter.filters[each.value.subject].id]
}

resource "aci_application_profile" "ap" {
  tenant_dn = aci_tenant.tenant.id
  name      = var.ap
}

resource "aci_application_epg" "epgs" {
  for_each = var.epgs

  application_profile_dn = aci_application_profile.ap.id
  name                   = each.value.name
  relation_fv_rs_bd      = aci_bridge_domain.bridge_domains[each.value.bd].id
}

locals {
  epg_contracts = flatten([
    for epg_key, epg in var.epgs : [
      for epg_contract_key, contract in epg.contracts : {
        epg_key          = epg_key
        epg_contract_key = epg_contract_key
        contract         = contract
      }
    ]
  ])
}

resource "aci_epg_to_contract" "epg_contracts" {
  for_each = {
    for item in local.epg_contracts : "${item.epg_key}_${item.epg_contract_key}" => item
  }

  application_epg_dn = aci_application_epg.epgs[each.value.epg_key].id
  contract_dn        = aci_contract.contracts[each.value.contract.name].id
  contract_type      = each.value.contract.type
}
