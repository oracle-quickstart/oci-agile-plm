# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



# Availability Domains
data "oci_identity_availability_domains" "this" {
  compartment_id = var.default_compartment_id
}

data "oci_core_services" "this" {
}

data "oci_core_subnets" "agile_plm_subnets" {
  #Required
  compartment_id = var.default_compartment_id
  vcn_id         = module.ent_base.vcn.id
}

data "oci_core_security_lists" "security_lists" {
  for_each = { search = "search" }
  #Required
  compartment_id = var.default_compartment_id
  vcn_id         = module.ent_base.vcn.id
}

resource "random_integer" "random_as_fault_domain" {
  count = var.plm_as_options != null ? (var.plm_as_options.num_inst != null ? var.plm_as_options.num_inst : local.plm_as_option_defaults.num_inst) : local.plm_as_option_defaults.num_inst
  min   = 1
  max   = 3
}

resource "random_integer" "random_fm_fault_domain" {
  count = var.plm_fm_options != null ? (var.plm_fm_options.num_inst != null ? var.plm_fm_options.num_inst : local.plm_fm_option_defaults.num_inst) : local.plm_fm_option_defaults.num_inst
  min   = 1
  max   = 3
}
