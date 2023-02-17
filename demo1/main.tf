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
  name      = "demo_vrf"
}

resource "aci_bridge_domain" "web_bd" {
  tenant_dn          = aci_tenant.tenant.id
  name               = "web_bd"
  relation_fv_rs_ctx = aci_vrf.vrf.id
}

resource "aci_bridge_domain" "app_bd" {
  tenant_dn          = aci_tenant.tenant.id
  name               = "app_bd"
  relation_fv_rs_ctx = aci_vrf.vrf.id
}

resource "aci_bridge_domain" "db_bd" {
  tenant_dn          = aci_tenant.tenant.id
  name               = "db_bd"
  relation_fv_rs_ctx = aci_vrf.vrf.id
}

resource "aci_subnet" "web_subnet" {
  parent_dn = aci_bridge_domain.web_bd.id
  ip        = "10.16.1.254/24"
}

resource "aci_subnet" "app_subnet" {
  parent_dn = aci_bridge_domain.app_bd.id
  ip        = "10.16.2.254/24"
}

resource "aci_subnet" "db_subnet" {
  parent_dn = aci_bridge_domain.db_bd.id
  ip        = "10.16.3.254/24"
}

resource "aci_filter" "web_app_filter" {
  name      = "web_app_filter"
  tenant_dn = aci_tenant.tenant.id
}

resource "aci_filter" "app_db_filter" {
  name      = "app_db_filter"
  tenant_dn = aci_tenant.tenant.id
}

resource "aci_filter_entry" "web_app_filter_entry" {
  filter_dn   = aci_filter.web_app_filter.id
  name        = "web_app_filter"
  d_from_port = "5000"
  d_to_port   = "5000"
  ether_t     = "ip"
  prot        = "tcp"
}

resource "aci_filter_entry" "app_db_filter_entry" {
  filter_dn   = aci_filter.app_db_filter.id
  name        = "app_db_filter"
  d_from_port = "1433"
  d_to_port   = "1433"
  ether_t     = "ip"
  prot        = "tcp"
}

resource "aci_contract" "web_app_contract" {
  tenant_dn = aci_tenant.tenant.id
  name      = "web_app_contract"
}

resource "aci_contract" "app_db_contract" {
  tenant_dn = aci_tenant.tenant.id
  name      = "app_db_contract"
}

resource "aci_contract_subject" "web_app_contract_subject" {
  contract_dn                  = aci_contract.web_app_contract.id
  name                         = "web_app_filter"
  relation_vz_rs_subj_filt_att = [aci_filter.web_app_filter.id]
}

resource "aci_contract_subject" "app_db_contract_subject" {
  contract_dn                  = aci_contract.app_db_contract.id
  name                         = "app_db_filter"
  relation_vz_rs_subj_filt_att = [aci_filter.app_db_filter.id]
}

resource "aci_application_profile" "ap" {
  tenant_dn = aci_tenant.tenant.id
  name      = "demo_ap"
}

resource "aci_application_epg" "web_epg" {
  application_profile_dn = aci_application_profile.ap.id
  name                   = "web_epg"
  relation_fv_rs_bd      = aci_bridge_domain.web_bd.id
}

resource "aci_application_epg" "app_epg" {
  application_profile_dn = aci_application_profile.ap.id
  name                   = "app_epg"
  relation_fv_rs_bd      = aci_bridge_domain.app_bd.id
}

resource "aci_application_epg" "db_epg" {
  application_profile_dn = aci_application_profile.ap.id
  name                   = "db_epg"
  relation_fv_rs_bd      = aci_bridge_domain.db_bd.id
}

resource "aci_epg_to_contract" "web_consumer" {
  application_epg_dn = aci_application_epg.web_epg.id
  contract_dn        = aci_contract.web_app_contract.id
  contract_type      = "consumer"
}

resource "aci_epg_to_contract" "app_provider" {
  application_epg_dn = aci_application_epg.app_epg.id
  contract_dn        = aci_contract.web_app_contract.id
  contract_type      = "provider"
}

resource "aci_epg_to_contract" "app_consumer" {
  application_epg_dn = aci_application_epg.app_epg.id
  contract_dn        = aci_contract.app_db_contract.id
  contract_type      = "consumer"
}

resource "aci_epg_to_contract" "db_provider" {
  application_epg_dn = aci_application_epg.db_epg.id
  contract_dn        = aci_contract.app_db_contract.id
  contract_type      = "provider"
}
