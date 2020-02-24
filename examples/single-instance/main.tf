# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



module "agile_plm" {
  source = "../../"

  ##################################
  # Common config
  ##################################

  # tenancy ocid
  tenancy_id = var.tenancy_id

  # Default Compartment id
  default_compartment_id = var.default_compartment_id

  # A list of ssh public keys to be loaded on the provisioned Agile PLM instances
  default_ssh_auth_keys = var.default_ssh_auth_keys

  # Compute instances ssh private key
  ssh_private_key_path = var.ssh_private_key_path

  # The generic OCI image name to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible.
  default_img_name = var.default_img_name

  # The generic OCI image ocid to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible. See https://docs.cloud.oracle.com/iaas/images/ for a listing of OCI-provided image OCIDs
  default_img_id = var.default_img_id

  ##################################
  # Database config
  ##################################

  # To provision or not the Agile PLM DB as DBCS
  provision_db = var.provision_db

  db_options = {
    ad                   = 2
    compartment_id       = null
    shape                = var.dbcs_instance_shape
    hostname             = null
    ssh_auth_keys        = null
    disk_redund          = "NORMAL"
    cluster_name         = null
    license_model        = null
    node_cnt             = 1
    time_zone            = null
    db_admin_password    = var.db_admin_password
    db_size_tbs          = 1
    db_name              = null
    db_edition           = var.dbcs_db_edition
    db_char_set          = null
    db_nchar_set         = null
    db_workload          = null
    db_pdb_name          = null
    db_ver               = null
    db_backup_days       = 2
    is_exacs             = false
    exacs_sparse_diskgrp = null
    bm_data_size_percent = null
    bm_cpu_cores         = null
    vm_data_size_gb      = 4096
  }


  ##################################
  # Load Balancers config
  ##################################

  # To provision or not the public_lb for the agile plm
  provision_pub_lb = var.provision_pub_lb

  # To provision or not the private_lb for the agile plm
  provision_priv_lb = var.provision_priv_lb

  lb_pub = {
    name         = null
    shape        = null
    cookie_name  = null
    app_hostname = "plm.test.oraclevcn.com"
    fm_hostname  = "fm.test.oraclevcn.com"
  }

  lb_priv = {
    name         = null
    shape        = null
    cookie_name  = null
    app_hostname = "fm.test.oraclevcn.com"
  }

  lb_pub_ssl_plm_as = {
    backends = {
      ca_certificate          = file(var.lb_ca_certificate)
      passphrase              = null
      private_key             = file(var.lb_private_key)
      public_certificate      = file(var.lb_public_certificate)
      verify_depth            = null
      verify_peer_certificate = false
    }
    listener = {
      ca_certificate          = file(var.lb_ca_certificate)
      passphrase              = null
      private_key             = file(var.lb_private_key)
      public_certificate      = file(var.lb_public_certificate)
      verify_depth            = null
      verify_peer_certificate = false
    }
  }
  lb_pub_ssl_plm_fm = {
    backends = {
      ca_certificate          = file(var.lb_ca_certificate)
      passphrase              = null
      private_key             = file(var.lb_private_key)
      public_certificate      = file(var.lb_public_certificate)
      verify_depth            = null
      verify_peer_certificate = false
    }
    listener = {
      ca_certificate          = file(var.lb_ca_certificate)
      passphrase              = null
      private_key             = file(var.lb_private_key)
      public_certificate      = file(var.lb_public_certificate)
      verify_depth            = null
      verify_peer_certificate = false
    }
  }

  lb_priv_ssl_plm_as = {
    backends = {
      ca_certificate          = file(var.lb_ca_certificate)
      passphrase              = null
      private_key             = file(var.lb_private_key)
      public_certificate      = file(var.lb_public_certificate)
      verify_depth            = null
      verify_peer_certificate = false
    }
    listener = {
      ca_certificate          = file(var.lb_ca_certificate)
      passphrase              = null
      private_key             = file(var.lb_private_key)
      public_certificate      = file(var.lb_public_certificate)
      verify_depth            = null
      verify_peer_certificate = false
    }
  }

  # The load balancer listening port
  lb_port = var.lb_port

  # LB - generic - Rule Set-specific variables
  rule_sets = var.rule_sets

  ##################################
  # Bastion host Config
  ##################################

  # Whether or not a bastion and all of its resources (subnet/NSG/compute instance) should be created.
  create_bastion = var.create_bastion

  # The bastion image name
  bastion_image_name = var.bastion_image_name

  bastion_ssh_src_cidrs = [
    "0.0.0.0/0"
  ]

  ##################################
  # Application Servers Config
  ##################################

  plm_as_options = {
    num_inst          = var.as_num_inst
    shape             = var.as_instances_shape
    boot_vol_size     = var.as_instances_boot_vol_size
    ssh_auth_keys     = null
    img_id            = var.default_img_id
    img_name          = var.default_img_name
    mkp_image_name    = var.default_mkp_image_name
    mkp_image_version = var.default_mkp_image_version
  }

  # The aditional block volumes size
  as_aditional_block_volume_size = var.as_aditional_block_volume_size

  # The aditional as block volume mount point
  as_aditional_block_volume_mount_point = var.as_aditional_block_volume_mount_point

  # The aditional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze
  as_volumes_backup_policy = var.as_volumes_backup_policy

  # The production port AS managed servers on a compute node.
  as_prod_port = var.as_prod_port

  # The admin port AS servers are listening on. The listening port for the AS WLS Admin Server.
  as_admin_port = var.as_admin_port

  ##################################
  # File Manager Servers Config
  ##################################

  plm_fm_options = {
    num_inst          = var.fm_num_inst
    shape             = var.fm_instances_shape
    boot_vol_size     = var.as_instances_boot_vol_size
    ssh_auth_keys     = null
    img_id            = var.default_img_id
    img_name          = var.default_img_name
    mkp_image_name    = var.default_mkp_image_name
    mkp_image_version = var.default_mkp_image_version
  }

  # The aditional block volumes size
  fm_aditional_block_volume_size = var.fm_aditional_block_volume_size

  # The aditional fm block volume mount point
  fm_aditional_block_volume_mount_point = var.fm_aditional_block_volume_mount_point

  # The aditional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze
  fm_volumes_backup_policy = var.fm_volumes_backup_policy

  # Agile PLM file manager port
  file_mgr_port = var.file_mgr_port

  ##################################
  # Ansible Servers Config
  ##################################

  # Whether or not an Ansible control machine and all of its resources (subnet/NSG/compute instance) should be created.
  create_ansible = var.create_ansible

  ##################################
  # DNS Servers Config
  ##################################

  # Whether or not DNS forwarders and all of their resources (subnet/NSG/compute instance) should be created.
  create_dns = var.create_dns

  dns_namespace_mappings = [
    {
      namespace = "anothervcn.oraclevcn.com."
      server    = "10.1.2.3"
    },
    {
      namespace = "onprem.local."
      server    = "172.16.3.2"
    }
  ]

  reverse_dns_mappings = [
    {
      cidr   = "10.0.0.0/16"
      server = "10.1.2.3"
    },
    {
      cidr   = "172.16.0.0/12"
      server = "172.16.3.2"
    }
  ]

  on_prem_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12"
  ]

  ##################################
  # Other Config
  ##################################
  create_svcgw = false
}
