# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  plm_as_option_defaults = {
    num_inst      = 2
    shape         = "VM.Standard1.1"
    boot_vol_size = 500
  }

  plm_as_options = {
    num_inst          = var.plm_as_options != null ? (var.plm_as_options.num_inst != null ? var.plm_as_options.num_inst : local.plm_as_option_defaults.num_inst) : local.plm_as_option_defaults.num_inst
    shape             = var.plm_as_options != null ? (var.plm_as_options.shape != null ? var.plm_as_options.shape : local.plm_as_option_defaults.shape) : local.plm_as_option_defaults.shape
    boot_vol_size     = var.plm_as_options != null ? (var.plm_as_options.boot_vol_size != null ? var.plm_as_options.boot_vol_size : local.plm_as_option_defaults.boot_vol_size) : local.plm_as_option_defaults.boot_vol_size
    ssh_auth_keys     = var.plm_as_options != null ? (var.plm_as_options.ssh_auth_keys != null ? var.plm_as_options.ssh_auth_keys : var.default_ssh_auth_keys) : var.default_ssh_auth_keys
    img_id            = var.plm_as_options != null ? (var.plm_as_options.img_id != null ? var.plm_as_options.img_id : var.default_img_id) : var.default_img_id
    img_name          = var.plm_as_options != null ? (var.plm_as_options.img_name != null ? var.plm_as_options.img_name : var.default_img_name) : var.default_img_name
    mkp_image_name    = var.plm_as_options != null ? (var.plm_as_options.mkp_image_name != null ? var.plm_as_options.mkp_image_name : null) : null
    mkp_image_version = var.plm_as_options != null ? (var.plm_as_options.mkp_image_version != null ? var.plm_as_options.mkp_image_version : null) : null
  }

  as_all_block_volumes = [for blk_vol in {
    for i in range(local.plm_as_options.num_inst) : "agile_plm_as-${i + 1}-volume01" => {
      volume = "agile_plm_as-${i + 1}-volume01",
      details = {
        volume_id        = contains(keys(module.as_block_storage.vols), "agile_plm_as-${i + 1}-volume01") ? module.as_block_storage.vols["agile_plm_as-${i + 1}-volume01"].id : ""
        attachment_type  = "iscsi",
        volume_mount_dir = var.as_aditional_block_volume_mount_point
      }
    }
  } : list(blk_vol)]

  fm_all_block_volumes = [for blk_vol in {
    for i in range(local.plm_fm_options.num_inst) : "agile_plm_fm-${i + 1}-volume01" => {
      volume = "agile_plm_fm-${i + 1}-volume01",
      details = {
        volume_id        = contains(keys(module.fm_block_storage.vols), "agile_plm_fm-${i + 1}-volume01") ? module.fm_block_storage.vols["agile_plm_fm-${i + 1}-volume01"].id : ""
        attachment_type  = "iscsi",
        volume_mount_dir = var.fm_aditional_block_volume_mount_point
      }
    }
  } : list(blk_vol)]

  plm_as_instances = {
    for i in range(local.plm_as_options.num_inst) :
    "plm_as_${i + 1}" => {
      ad                     = i % local.num_ads
      compartment_id         = var.default_compartment_id
      shape                  = local.plm_as_options.shape
      subnet_id              = module.oci_subnets.subnets != null ? module.oci_subnets.subnets.app.id : null
      is_monitoring_disabled = null
      assign_public_ip       = false
      vnic_defined_tags      = null
      vnic_display_name      = null
      vnic_freeform_tags     = null
      nsg_ids                = [length(module.oci_network_security_policies.nsgs) > 0 ? module.oci_network_security_policies.nsgs.app_server.id : null]
      private_ip             = null
      skip_src_dest_check    = false
      defined_tags           = null
      display_name           = "plm_as_${i + 1}"
      extended_metadata      = null
      fault_domain           = "FAULT-DOMAIN-${random_integer.random_as_fault_domain[i].result}"
      freeform_tags          = null
      hostname_label         = "plmas${i + 1}"
      ipxe_script            = null
      pv_encr_trans_enabled  = null
      ssh_authorized_keys    = local.plm_as_options.ssh_auth_keys
      ssh_private_keys       = [var.ssh_private_key_path]
      bastion_ip             = module.ent_base.bastion_instance != null ? module.ent_base.bastion_instance.public_ip : null
      user_data              = null
      image_name             = local.plm_as_options.img_name
      mkp_image_name         = local.plm_as_options.mkp_image_name
      mkp_image_name_version = local.plm_as_options.mkp_image_version
      source_id              = local.plm_as_options.img_id
      source_type            = "image"
      boot_vol_size_gbs      = local.plm_as_options.boot_vol_size
      kms_key_id             = null
      preserve_boot_volume   = true
      instance_timeout       = null
      sec_vnics              = null
      block_volumes          = [for blk_vol in local.as_all_block_volumes : blk_vol[0].details if blk_vol[0].volume == "agile_plm_as-${i + 1}-volume01"]
      mount_blk_vols         = true
      cons_conn_create       = false
      cons_conn_def_tags     = {}
      cons_conn_free_tags    = {}
    }
  }

  plm_fm_option_defaults = {
    num_inst      = 2
    shape         = "VM.Standard1.1"
    boot_vol_size = 500
  }

  plm_fm_options = {
    num_inst          = var.plm_fm_options != null ? (var.plm_fm_options.num_inst != null ? var.plm_fm_options.num_inst : local.plm_fm_option_defaults.num_inst) : local.plm_fm_option_defaults.num_inst
    shape             = var.plm_fm_options != null ? (var.plm_fm_options.shape != null ? var.plm_fm_options.shape : local.plm_fm_option_defaults.shape) : local.plm_fm_option_defaults.shape
    boot_vol_size     = var.plm_fm_options != null ? (var.plm_fm_options.boot_vol_size != null ? var.plm_fm_options.boot_vol_size : local.plm_fm_option_defaults.boot_vol_size) : local.plm_fm_option_defaults.boot_vol_size
    ssh_auth_keys     = var.plm_fm_options != null ? (var.plm_fm_options.ssh_auth_keys != null ? var.plm_fm_options.ssh_auth_keys : var.default_ssh_auth_keys) : var.default_ssh_auth_keys
    img_id            = var.plm_fm_options != null ? (var.plm_fm_options.img_id != null ? var.plm_fm_options.img_id : var.default_img_id) : var.default_img_id
    img_name          = var.plm_fm_options != null ? (var.plm_fm_options.img_name != null ? var.plm_fm_options.img_name : var.default_img_name) : var.default_img_name
    mkp_image_name    = var.plm_fm_options != null ? (var.plm_fm_options.mkp_image_name != null ? var.plm_fm_options.mkp_image_name : null) : null
    mkp_image_version = var.plm_fm_options != null ? (var.plm_fm_options.mkp_image_version != null ? var.plm_fm_options.mkp_image_version : null) : null
  }

  plm_fm_instances = {
    for i in range(local.plm_fm_options.num_inst) :
    "plm_fm_${i + 1}" => {
      ad                     = i % local.num_ads
      compartment_id         = var.default_compartment_id
      shape                  = local.plm_fm_options.shape
      subnet_id              = module.oci_subnets.subnets != null ? module.oci_subnets.subnets.files.id : null
      is_monitoring_disabled = null
      assign_public_ip       = false
      vnic_defined_tags      = null
      vnic_display_name      = null
      vnic_freeform_tags     = null
      nsg_ids                = [length(module.oci_network_security_policies.nsgs) > 0 ? module.oci_network_security_policies.nsgs.file_manager.id : null]
      private_ip             = null
      skip_src_dest_check    = false
      defined_tags           = null
      display_name           = "plm_fs_${i + 1}"
      extended_metadata      = null
      fault_domain           = "FAULT-DOMAIN-${random_integer.random_fm_fault_domain[i].result}"
      freeform_tags          = null
      hostname_label         = "plmfs${i + 1}"
      ipxe_script            = null
      pv_encr_trans_enabled  = null
      ssh_authorized_keys    = local.plm_fm_options.ssh_auth_keys
      ssh_private_keys       = [var.ssh_private_key_path]
      bastion_ip             = module.ent_base.bastion_instance != null ? module.ent_base.bastion_instance.public_ip : null
      user_data              = null
      image_name             = local.plm_fm_options.img_name
      mkp_image_name         = local.plm_fm_options.mkp_image_name
      mkp_image_name_version = local.plm_fm_options.mkp_image_version
      source_id              = local.plm_fm_options.img_id
      source_type            = null
      boot_vol_size_gbs      = local.plm_fm_options.boot_vol_size
      kms_key_id             = null
      preserve_boot_volume   = true
      instance_timeout       = null
      sec_vnics              = null
      block_volumes          = [for blk_vol in local.fm_all_block_volumes : blk_vol[0].details if blk_vol[0].volume == "agile_plm_fm-${i + 1}-volume01"]
      mount_blk_vols         = true
      cons_conn_create       = false
      cons_conn_def_tags     = {}
      cons_conn_free_tags    = {}
    }
  }
}

# create as instances
module "oci_instances_as" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-compute-instance.git?ref=v0.10.2"

  default_compartment_id = var.default_compartment_id
  instances              = local.plm_as_instances

}

# create fm instances
module "oci_instances_fm" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-compute-instance.git?ref=v0.10.2"

  default_compartment_id = var.default_compartment_id
  instances              = local.plm_fm_instances
}