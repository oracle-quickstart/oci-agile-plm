# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# create aditional block storage for as instances
module "as_block_storage" {

  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-block-storage.git?ref=v0.1.5"

  default_compartment_id     = var.default_compartment_id
  default_ad                 = 0
  default_size_in_gbs        = 50
  default_backup_policy_name = "Bronze"
  default_defined_tags       = {}
  default_freeform_tags      = {}

  vol_grps = {}

  vols = {
    for i in range(local.plm_as_options.num_inst) :
    "agile_plm_as-${i + 1}-volume01" => {
      compartment_id = var.default_compartment_id
      source_id      = null
      source_type    = null

      # distribute volumes across ADs
      ad = i % length(data.oci_identity_availability_domains.availability_domains.availability_domains)

      size_in_gbs        = var.as_aditional_block_volume_size
      backup_policy_name = var.as_volumes_backup_policy
      defined_tags       = null
      freeform_tags      = null
      kms_key_id         = null
      vol_grp_name       = null
    }
  }
}

# create aditional block storage for fm instances
module "fm_block_storage" {

  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-block-storage.git?ref=v0.1.5"

  default_compartment_id     = var.default_compartment_id
  default_ad                 = 0
  default_size_in_gbs        = 50
  default_backup_policy_name = "Bronze"
  default_defined_tags       = {}
  default_freeform_tags      = {}

  vol_grps = {}

  vols = {
    for i in range(local.plm_fm_options.num_inst) :
    "agile_plm_fm-${i + 1}-volume01" => {
      compartment_id = var.default_compartment_id
      source_id      = null
      source_type    = null

      # distribute volumes across ADs
      ad = i % length(data.oci_identity_availability_domains.availability_domains.availability_domains)

      size_in_gbs        = var.fm_aditional_block_volume_size
      backup_policy_name = var.fm_volumes_backup_policy
      defined_tags       = null
      freeform_tags      = null
      kms_key_id         = null
      vol_grp_name       = null
    }
  }
}

data "oci_identity_availability_domains" "availability_domains" {
  #Required
  compartment_id = var.tenancy_id
}