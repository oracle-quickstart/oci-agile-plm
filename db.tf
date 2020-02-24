# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  db_options_defaults = {
    ad             = 0
    compartment_id = var.default_compartment_id
    shape          = "VM.Standard2.4"
    hostname       = "agileplm"
    ssh_auth_keys  = var.default_ssh_auth_keys
    disk_redund    = "HIGH"
    cluster_name   = "agileplm"
    license_model  = "LICENSE_INCLUDED"
    node_cnt       = 2
    time_zone      = null

    db_size_tbs    = 1
    db_name        = "agileplm"
    db_edition     = "ENTERPRISE_EDITION_EXTREME_PERFORMANCE"
    db_char_set    = "AL32UTF8"
    db_nchar_set   = "AL16UTF16"
    db_workload    = "OLTP"
    db_pdb_name    = "plugaplm"
    db_ver         = "18.8.0.0"
    db_backup_days = 31

    is_exacs             = false
    exacs_sparse_diskgrp = true

    bm_data_size_percent = 80
    bm_cpu_cores         = null

    vm_data_size_gb = 1024
  }

  is_exacs = var.db_options != null ? (var.db_options.is_exacs != null ? var.db_options.is_exacs : local.db_options_defaults.is_exacs) : local.db_options_defaults.is_exacs

  ssh_auth_keys = var.db_options != null ? (
    var.db_options.ssh_auth_keys != null ?
    [for i in var.db_options.ssh_auth_keys : chomp(file(i))] :
    [for i in local.db_options_defaults.ssh_auth_keys : chomp(file(i))]
  ) : [for i in local.db_options_defaults.ssh_auth_keys : chomp(file(i))]
  db_ad = var.db_options != null ? (var.db_options.ad != null ? var.db_options.ad : local.db_options_defaults.ad) : local.db_options_defaults.ad
}


resource "oci_database_db_system" "this_not_exacs" {
  count = var.provision_db == false ? 0 : local.is_exacs == true ? 0 : 1

  availability_domain = lookup(data.oci_identity_availability_domains.this.availability_domains[local.db_ad], "name")
  compartment_id      = var.db_options != null ? (var.db_options.compartment_id != null ? var.db_options.compartment_id : local.db_options_defaults.compartment_id) : local.db_options_defaults.compartment_id
  database_edition    = var.db_options != null ? (var.db_options.db_edition != null ? var.db_options.db_edition : local.db_options_defaults.db_edition) : local.db_options_defaults.db_edition
  db_home {
    database {
      admin_password = var.db_options != null ? (var.db_options.db_admin_password != null ? var.db_options.db_admin_password : null) : null
      character_set  = var.db_options != null ? (var.db_options.db_char_set != null ? var.db_options.db_char_set : local.db_options_defaults.db_char_set) : local.db_options_defaults.db_char_set
      db_backup_config {
        auto_backup_enabled     = true
        recovery_window_in_days = var.db_options != null ? (var.db_options.db_backup_days != null ? var.db_options.db_backup_days : local.db_options_defaults.db_backup_days) : local.db_options_defaults.db_backup_days
      }
      db_name     = var.db_options != null ? (var.db_options.db_name != null ? var.db_options.db_name : local.db_options_defaults.db_name) : local.db_options_defaults.db_name
      db_workload = var.db_options != null ? (var.db_options.db_workload != null ? var.db_options.db_workload : local.db_options_defaults.db_workload) : local.db_options_defaults.db_workload
      # defined_tags      = {}
      # freeform_tags     = {}
      ncharacter_set = var.db_options != null ? (var.db_options.db_nchar_set != null ? var.db_options.db_nchar_set : local.db_options_defaults.db_nchar_set) : local.db_options_defaults.db_nchar_set
      pdb_name       = var.db_options != null ? (var.db_options.db_pdb_name != null ? var.db_options.db_pdb_name : local.db_options_defaults.db_pdb_name) : local.db_options_defaults.db_pdb_name
    }
    db_version   = var.db_options != null ? (var.db_options.db_ver != null ? var.db_options.db_ver : local.db_options_defaults.db_ver) : local.db_options_defaults.db_ver
    display_name = var.db_options != null ? (var.db_options.db_name != null ? var.db_options.db_name : local.db_options_defaults.db_name) : local.db_options_defaults.db_name
  }
  hostname        = var.db_options != null ? (var.db_options.hostname != null ? var.db_options.hostname : local.db_options_defaults.hostname) : local.db_options_defaults.hostname
  shape           = var.db_options != null ? (var.db_options.shape != null ? var.db_options.shape : local.db_options_defaults.shape) : local.db_options_defaults.shape
  ssh_public_keys = local.ssh_auth_keys
  subnet_id       = module.oci_subnets.subnets.db.id

  cluster_name   = var.db_options != null ? (var.db_options.cluster_name != null ? var.db_options.cluster_name : local.db_options_defaults.cluster_name) : local.db_options_defaults.cluster_name
  cpu_core_count = var.db_options != null ? (var.db_options.bm_cpu_cores != null ? var.db_options.bm_cpu_cores : local.db_options_defaults.bm_cpu_cores) : local.db_options_defaults.bm_cpu_cores

  data_storage_percentage = var.db_options != null ? (var.db_options.bm_data_size_percent != null ? var.db_options.bm_data_size_percent : local.db_options_defaults.bm_data_size_percent) : local.db_options_defaults.bm_data_size_percent
  data_storage_size_in_gb = var.db_options != null ? (var.db_options.vm_data_size_gb != null ? var.db_options.vm_data_size_gb : local.db_options_defaults.vm_data_size_gb) : local.db_options_defaults.vm_data_size_gb
  db_system_options {
    # Used LVM for fast provisioning - under 15 minutes. ASM is for production purpose - but slow provisioning - aprox. 1h.
    storage_management = "LVM"
  }
  # defined_tags          = {}
  # freeform_tags         = {}
  disk_redundancy = var.db_options != null ? (var.db_options.disk_redund != null ? var.db_options.disk_redund : local.db_options_defaults.disk_redund) : local.db_options_defaults.disk_redund
  display_name    = var.db_options != null ? (var.db_options.db_name != null ? var.db_options.db_name : local.db_options_defaults.db_name) : local.db_options_defaults.db_name
  license_model   = var.db_options != null ? (var.db_options.license_model != null ? var.db_options.license_model : local.db_options_defaults.license_model) : local.db_options_defaults.license_model
  node_count      = var.db_options != null ? (var.db_options.node_cnt != null ? var.db_options.node_cnt : local.db_options_defaults.node_cnt) : local.db_options_defaults.node_cnt
  nsg_ids         = [module.oci_network_security_policies.nsgs.db.id]
  source          = "NONE"
  time_zone       = var.db_options != null ? (var.db_options.time_zone != null ? var.db_options.time_zone : local.db_options_defaults.time_zone) : local.db_options_defaults.time_zone
}

resource "oci_database_db_system" "this_exacs" {
  count = var.provision_db == false ? 0 : local.is_exacs == true ? 1 : 0

  availability_domain = lookup(data.oci_identity_availability_domains.this.availability_domains[local.db_ad], "name")
  compartment_id      = var.db_options != null ? (var.db_options.compartment_id != null ? var.db_options.compartment_id : local.db_options_defaults.compartment_id) : local.db_options_defaults.compartment_id
  database_edition    = var.db_options != null ? (var.db_options.db_edition != null ? var.db_options.db_edition : local.db_options_defaults.db_edition) : local.db_options_defaults.db_edition
  db_home {
    database {
      admin_password = var.db_options != null ? (var.db_options.db_admin_password != null ? var.db_options.db_admin_password : null) : null
      character_set  = var.db_options != null ? (var.db_options.db_char_set != null ? var.db_options.db_char_set : local.db_options_defaults.db_char_set) : local.db_options_defaults.db_char_set
      db_backup_config {
        auto_backup_enabled     = true
        recovery_window_in_days = var.db_options != null ? (var.db_options.db_backup_days != null ? var.db_options.db_backup_days : local.db_options_defaults.db_backup_days) : local.db_options_defaults.db_backup_days
      }
      db_name     = var.db_options != null ? (var.db_options.db_name != null ? var.db_options.db_name : local.db_options_defaults.db_name) : local.db_options_defaults.db_name
      db_workload = var.db_options != null ? (var.db_options.db_workload != null ? var.db_options.db_workload : local.db_options_defaults.db_workload) : local.db_options_defaults.db_workload
      # defined_tags      = {}
      # freeform_tags     = {}
      ncharacter_set = var.db_options != null ? (var.db_options.db_nchar_set != null ? var.db_options.db_nchar_set : local.db_options_defaults.db_nchar_set) : local.db_options_defaults.db_nchar_set
      pdb_name       = var.db_options != null ? (var.db_options.db_pdb_name != null ? var.db_options.db_pdb_name : local.db_options_defaults.db_pdb_name) : local.db_options_defaults.db_pdb_name
    }
    db_version   = var.db_options != null ? (var.db_options.db_ver != null ? var.db_options.db_ver : local.db_options_defaults.db_ver) : local.db_options_defaults.db_ver
    display_name = var.db_options != null ? (var.db_options.db_name != null ? var.db_options.db_name : local.db_options_defaults.db_name) : local.db_options_defaults.db_name
  }
  hostname        = var.db_options != null ? (var.db_options.hostname != null ? var.db_options.hostname : local.db_options_defaults.hostname) : local.db_options_defaults.hostname
  shape           = var.db_options != null ? (var.db_options.shape != null ? var.db_options.shape : local.db_options_defaults.shape) : local.db_options_defaults.shape
  ssh_public_keys = local.ssh_auth_keys
  subnet_id       = module.oci_subnets.subnets.db.id

  backup_network_nsg_ids = local.is_exacs == true ? [module.oci_network_security_policies_db_backup.nsgs.db_backup.id] : []
  backup_subnet_id       = local.is_exacs == true ? module.oci_subnets_db_backup.subnets.db_backup.id : null

  cluster_name   = var.db_options != null ? (var.db_options.cluster_name != null ? var.db_options.cluster_name : local.db_options_defaults.cluster_name) : local.db_options_defaults.cluster_name
  cpu_core_count = var.db_options != null ? (var.db_options.bm_cpu_cores != null ? var.db_options.bm_cpu_cores : local.db_options_defaults.bm_cpu_cores) : local.db_options_defaults.bm_cpu_cores

  data_storage_percentage = var.db_options != null ? (var.db_options.bm_data_size_percent != null ? var.db_options.bm_data_size_percent : local.db_options_defaults.bm_data_size_percent) : local.db_options_defaults.bm_data_size_percent
  disk_redundancy         = var.db_options != null ? (var.db_options.disk_redund != null ? var.db_options.disk_redund : local.db_options_defaults.disk_redund) : local.db_options_defaults.disk_redund
  display_name            = var.db_options != null ? (var.db_options.db_name != null ? var.db_options.db_name : local.db_options_defaults.db_name) : local.db_options_defaults.db_name
  license_model           = var.db_options != null ? (var.db_options.license_model != null ? var.db_options.license_model : local.db_options_defaults.license_model) : local.db_options_defaults.license_model
  node_count              = var.db_options != null ? (var.db_options.node_cnt != null ? var.db_options.node_cnt : local.db_options_defaults.node_cnt) : local.db_options_defaults.node_cnt
  nsg_ids                 = [module.oci_network_security_policies.nsgs.db.id]
  source                  = "NONE"
  sparse_diskgroup        = var.db_options != null ? (var.db_options.exacs_sparse_diskgrp != null ? var.db_options.exacs_sparse_diskgrp : local.db_options_defaults.exacs_sparse_diskgrp) : local.db_options_defaults.exacs_sparse_diskgrp
  time_zone               = var.db_options != null ? (var.db_options.time_zone != null ? var.db_options.time_zone : local.db_options_defaults.time_zone) : local.db_options_defaults.time_zone
}
