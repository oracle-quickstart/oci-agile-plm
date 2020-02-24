# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.




locals {
  rt_int     = length(module.ent_base.route_tables) > 0 ? module.ent_base.route_tables.internal.id : null
  rt_int_pub = length(module.ent_base.route_tables) > 0 ? module.ent_base.route_tables.internal_public.id : null
  rt_ext     = length(module.ent_base.route_tables) > 0 ? module.ent_base.route_tables.external.id : null

  dns_int = length(module.ent_base.dhcp_options) > 0 ? module.ent_base.dhcp_options.internal.id : null
  dns_vcn = length(module.ent_base.dhcp_options) > 0 ? module.ent_base.dhcp_options.dns_forwarders.id : null

  vcn_wide_sl = [module.ent_base.vcn_wide_sl != null ? module.ent_base.vcn_wide_sl.id : null]

  files_subnet_defaults = {
    cidr      = "192.168.0.16/28"
    dns_label = "files"
  }
  app_subnet_defaults = {
    cidr      = "192.168.0.64/26"
    dns_label = "app"
  }
  db_subnet_defaults = {
    cidr      = "192.168.0.32/28"
    dns_label = "db"
  }
  db_backup_subnet_defaults = {
    cidr      = "192.168.0.48/28"
    dns_label = "dbbackup"
  }
  lb_pub_subnet_defaults = {
    cidr      = "192.168.1.8/29"
    dns_label = "lbpub"
  }
  lb_priv_subnet_defaults = {
    cidr      = "192.168.0.8/29"
    dns_label = "lbpriv"
  }
}

locals {
  subnet_names = ["files", "app", "db", "lb_pub", "lb_priv"]

  all_subnets = {
    files = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.files_subnet != null ? (var.files_subnet.cidr != null ? var.files_subnet.cidr : local.files_subnet_defaults.cidr) : local.files_subnet_defaults.cidr
      dns_label         = var.files_subnet != null ? (var.files_subnet.dns_label != null ? var.files_subnet.dns_label : local.files_subnet_defaults.dns_label) : local.files_subnet_defaults.dns_label
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      private           = true
      ad                = null
      dhcp_options_id   = local.dns_int
      route_table_id    = local.rt_int
      security_list_ids = local.vcn_wide_sl
    }
    app = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.app_subnet != null ? (var.app_subnet.cidr != null ? var.app_subnet.cidr : local.app_subnet_defaults.cidr) : local.app_subnet_defaults.cidr
      dns_label         = var.app_subnet != null ? (var.app_subnet.dns_label != null ? var.app_subnet.dns_label : local.app_subnet_defaults.dns_label) : local.app_subnet_defaults.dns_label
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      private           = true
      ad                = null
      dhcp_options_id   = local.dns_int
      route_table_id    = local.rt_int
      security_list_ids = local.vcn_wide_sl
    }
    db = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.db_subnet != null ? (var.db_subnet.cidr != null ? var.db_subnet.cidr : local.db_subnet_defaults.cidr) : local.db_subnet_defaults.cidr
      dns_label         = var.db_subnet != null ? (var.db_subnet.dns_label != null ? var.db_subnet.dns_label : local.db_subnet_defaults.dns_label) : local.db_subnet_defaults.dns_label
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      private           = true
      ad                = null
      dhcp_options_id   = local.dns_vcn
      route_table_id    = local.rt_int
      security_list_ids = local.vcn_wide_sl
    }
    lb_pub = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.lb_pub_subnet != null ? (var.lb_pub_subnet.cidr != null ? var.lb_pub_subnet.cidr : local.lb_pub_subnet_defaults.cidr) : local.lb_pub_subnet_defaults.cidr
      dns_label         = var.lb_pub_subnet != null ? (var.lb_pub_subnet.dns_label != null ? var.lb_pub_subnet.dns_label : local.lb_pub_subnet_defaults.dns_label) : local.lb_pub_subnet_defaults.dns_label
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      private           = false
      ad                = null
      dhcp_options_id   = null
      route_table_id    = local.rt_ext
      security_list_ids = null
    }
    lb_priv = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.lb_priv_subnet != null ? (var.lb_priv_subnet.cidr != null ? var.lb_priv_subnet.cidr : local.lb_priv_subnet_defaults.cidr) : local.lb_priv_subnet_defaults.cidr
      dns_label         = var.lb_priv_subnet != null ? (var.lb_priv_subnet.dns_label != null ? var.lb_priv_subnet.dns_label : local.lb_priv_subnet_defaults.dns_label) : local.lb_priv_subnet_defaults.dns_label
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      private           = true
      ad                = null
      dhcp_options_id   = null
      route_table_id    = local.rt_int
      security_list_ids = null
    }
  }
  subnets = {
    for subnet_name in local.subnet_names : subnet_name => local.all_subnets[subnet_name] if(
      (subnet_name == "files" && var.plm_fm_options.num_inst > 0) ||
      (subnet_name == "app" && var.plm_as_options.num_inst > 0) ||
      (subnet_name == "db" && var.provision_db == true) ||
      (subnet_name == "lb_pub" && var.provision_pub_lb == true) ||
      (subnet_name == "lb_priv" && var.provision_priv_lb == true)
    )
  }
}

module "oci_subnets" {

  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-subnet.git?ref=v0.9.6"

  default_compartment_id = var.default_compartment_id
  vcn_id                 = module.ent_base.vcn.id
  vcn_cidr               = module.ent_base.vcn.cidr_block
  default_defined_tags   = var.default_defined_tags
  default_freeform_tags  = var.default_freeform_tags

  subnets = local.subnets
}

# there's an issue with how merge calculates things, forcing us to use a separate module, rather than merging conditional maps together...
module "oci_subnets_db_backup" {

  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-subnet.git?ref=v0.9.6"

  default_compartment_id = var.default_compartment_id
  vcn_id                 = module.ent_base.vcn.id
  vcn_cidr               = module.ent_base.vcn.cidr_block
  default_defined_tags   = var.default_defined_tags
  default_freeform_tags  = var.default_freeform_tags

  subnets = local.is_exacs != true ? {} : {
    db_backup = {
      compartment_id    = null
      defined_tags      = null
      freeform_tags     = null
      dynamic_cidr      = false
      cidr              = var.db_backup_subnet != null ? (var.db_backup_subnet.cidr != null ? var.db_backup_subnet.cidr : local.db_backup_subnet_defaults.cidr) : local.db_backup_subnet_defaults.cidr
      dns_label         = var.db_backup_subnet != null ? (var.db_backup_subnet.dns_label != null ? var.db_backup_subnet.dns_label : local.db_backup_subnet_defaults.dns_label) : local.db_backup_subnet_defaults.dns_label
      cidr_len          = null
      cidr_num          = null
      enable_dns        = true
      private           = true
      ad                = null
      dhcp_options_id   = local.dns_vcn
      route_table_id    = local.rt_int
      security_list_ids = local.vcn_wide_sl
    }
  }
}
