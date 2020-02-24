# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  dns_forwarders = distinct(concat(
    [for i in var.dns_namespace_mappings :
      "${i.server}/32"
    ],
    [for i in var.reverse_dns_mappings :
      "${i.server}/32"
    ]
  ))

  num_ads = length(data.oci_identity_availability_domains.this.availability_domains)
  ad1     = 0 % local.num_ads
  ad2     = 1 % local.num_ads
  ad3     = 2 % local.num_ads

  dns_forwarder_defaults = {
    1 = {
      ad         = local.ad1
      private_ip = "192.168.0.2"
    },
    2 = {
      ad         = local.ad2
      private_ip = "192.168.0.3"
    }
  }

  vcn_defaults = {
    name      = "agileplm"
    cidr      = "192.168.0.0/23"
    dns_label = "agileplm"
  }

  bastion_subnet_defaults = {
    cidr      = "192.168.1.0/29"
    dns_label = "bastion"
  }
  bastion_subnet_cidr = var.bastion_subnet != null ? (var.bastion_subnet.cidr != null ? var.bastion_subnet.cidr : local.bastion_subnet_defaults.cidr) : local.bastion_subnet_defaults.cidr
  ansible_subnet_defaults = {
    cidr      = "192.168.0.252/30"
    dns_label = "ansible"
  }
  dns_subnet_defaults = {
    cidr      = "192.168.0.0/29"
    dns_label = "dns"
  }
}

module "ent_base" {
  source = "github.com/oracle-quickstart/oci-arch-enterprise-base.git?ref=v0.0.4"

  default_compartment_id = var.default_compartment_id
  default_ssh_auth_keys  = var.default_ssh_auth_keys
  default_img_name       = var.default_img_name

  vcn_cidr      = var.vcn != null ? (var.vcn.cidr != null ? var.vcn.cidr : local.vcn_defaults.cidr) : local.vcn_defaults.cidr
  vcn_dns_label = var.vcn != null ? (var.vcn.dns_label != null ? var.vcn.dns_label : local.vcn_defaults.dns_label) : local.vcn_defaults.dns_label
  vcn_name      = var.vcn != null ? (var.vcn.name != null ? var.vcn.name : local.vcn_defaults.name) : local.vcn_defaults.name

  internal_drg_routes = var.on_prem_cidrs

  create_drg   = var.create_drg
  create_igw   = var.create_igw
  create_natgw = var.create_natgw
  create_svcgw = var.create_svcgw

  create_bastion = var.create_bastion
  bastion_options = {
    subnet_compartment_id   = null
    subnet_name             = "bastion"
    subnet_dns_label        = var.bastion_subnet != null ? (var.bastion_subnet.dns_label != null ? var.bastion_subnet.dns_label : local.bastion_subnet_defaults.dns_label) : local.bastion_subnet_defaults.dns_label
    subnet_cidr             = local.bastion_subnet_cidr
    instance_compartment_id = null
    instance_ad             = 0
    instance_name           = "bastion"
    instance_dns_label      = "bastion"
    instance_shape          = "VM.Standard2.1"
    ssh_auth_keys           = null
    ssh_src_cidrs           = var.bastion_ssh_src_cidrs
    image_name              = var.bastion_image_name
    image_id                = null
    allow_int_routes        = true
    private_ip              = null
    public_ip               = var.bastion_public_ip
    use_default_nsg_rules   = true
    route_table_id          = null
    freeform_tags           = null
    defined_tags            = null
  }

  create_ansible = var.create_ansible
  ansible_options = {
    subnet_compartment_id   = null
    subnet_name             = "ansible"
    subnet_dns_label        = var.ansible_subnet != null ? (var.ansible_subnet.dns_label != null ? var.ansible_subnet.dns_label : local.ansible_subnet_defaults.dns_label) : local.ansible_subnet_defaults.dns_label
    subnet_cidr             = var.ansible_subnet != null ? (var.ansible_subnet.cidr != null ? var.ansible_subnet.cidr : local.ansible_subnet_defaults.cidr) : local.ansible_subnet_defaults.cidr
    instance_compartment_id = null
    instance_ad             = 0
    instance_name           = "ansible"
    instance_dns_label      = "ansible"
    instance_shape          = null
    ssh_auth_keys           = null
    ssh_src_cidrs           = [local.bastion_subnet_cidr]
    image_name              = var.bastion_image_name
    image_id                = null
    allow_int_routes        = true
    private_ip              = null
    public_ip               = false
    use_default_nsg_rules   = true
    route_table_id          = null
    freeform_tags           = null
    defined_tags            = null
  }

  create_dns = var.create_dns
  dns_options = {
    subnet_compartment_id   = null
    subnet_name             = "dns"
    subnet_dns_label        = var.dns_subnet != null ? (var.dns_subnet.dns_label != null ? var.dns_subnet.dns_label : local.dns_subnet_defaults.dns_label) : local.dns_subnet_defaults.dns_label
    subnet_cidr             = var.dns_subnet != null ? (var.dns_subnet.cidr != null ? var.dns_subnet.cidr : local.dns_subnet_defaults.cidr) : local.dns_subnet_defaults.cidr
    instance_compartment_id = null
    instance_shape          = null
    ssh_auth_keys           = null
    image_id                = null
    image_name              = var.bastion_image_name
    public_ip               = false
    allow_int_routes        = true
    dns_src_cidrs           = null
    dns_dst_cidrs           = local.dns_forwarders
    use_default_nsg_rules   = true
    route_table_id          = null
    freeform_tags           = null
    defined_tags            = null
  }

  dns_forwarder_1 = var.dns_forwarder_1 == null ? null : {
    ad             = var.dns_forwarder_1 != null ? (var.dns_forwarder_1.ad != null ? var.dns_forwarder_1.ad : local.dns_forwarder_defaults.1.ad) : local.dns_forwarder_defaults.1.ad
    fd             = null
    private_ip     = var.dns_forwarder_1 != null ? (var.dns_forwarder_1.private_ip != null ? var.dns_forwarder_1.private_ip : local.dns_forwarder_defaults.1.private_ip) : local.dns_forwarder_defaults.1.private_ip
    name           = null
    hostname_label = null
    kms_key_id     = null
  }
  dns_forwarder_2 = var.dns_forwarder_2 == null ? null : {
    ad             = var.dns_forwarder_2 != null ? (var.dns_forwarder_2.ad != null ? var.dns_forwarder_2.ad : local.dns_forwarder_defaults.2.ad) : local.dns_forwarder_defaults.2.ad
    fd             = null
    private_ip     = var.dns_forwarder_2 != null ? (var.dns_forwarder_2.private_ip != null ? var.dns_forwarder_2.private_ip : local.dns_forwarder_defaults.2.private_ip) : local.dns_forwarder_defaults.1.private_ip
    name           = null
    hostname_label = null
    kms_key_id     = null
  }

  existing_dns_forwarder_ips = var.existing_dns_forwarder_ips

  dns_namespace_mappings = var.dns_namespace_mappings
  reverse_dns_mappings   = var.reverse_dns_mappings
}
