# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



variable "tenancy_id" {}

variable "default_compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
}
variable "default_defined_tags" {
  type        = map(string)
  description = "The different defined tags that are applied to each object by default."
  default     = {}
}
variable "default_freeform_tags" {
  type        = map(string)
  description = "The different freeform tags that are applied to each object by default."
  default     = {}
}
variable "default_img_id" {
  type        = string
  description = "The default image OCID to use for compute resources (unless otherwise specified)."
  default     = null
}
variable "default_img_name" {
  type        = string
  description = "The default image OCID to use for compute resources (unless otherwise specified)."
  default     = null
}

variable "default_ssh_auth_keys" {
  type        = list(string)
  description = "The default SSH public key(s) that should be set as authorized SSH keys (unless otherwise specified)."
}

# Compute instances ssh private key
variable "ssh_private_key_path" {
  description = "Compute instances ssh public key"
}

# VCN
variable "vcn" {
  type = object({
    name      = string,
    cidr      = string,
    dns_label = string
  })
  description = "Options for the VCN."
  default     = null
}

variable "create_igw" {
  type        = bool
  description = "Whether or not to create a IGW in the VCN (default: true)."
  default     = true
}
variable "create_natgw" {
  type        = bool
  description = "Whether or not to create a NAT Gateway in the VCN (default: true)."
  default     = true
}
variable "create_svcgw" {
  type        = bool
  description = "Whether or not to create a Service Gateway in the VCN (default: true)."
  default     = true
}
variable "create_drg" {
  type        = bool
  description = "Whether or not to create a Dynamic Routing Gateway in the VCN (default: true)."
  default     = true
}

# bastion
variable "create_bastion" {
  type        = bool
  description = "Whether or not a bastion and all of its resources (subnet/NSG/compute instance) should be created."
  default     = true
}
variable "bastion_subnet" {
  type = object({
    cidr      = string,
    dns_label = string
  })
  description = "Options for the bastion subnet."
  default     = null
}
variable "bastion_ssh_src_cidrs" {
  type        = list(string)
  description = "The CIDRs that are allowed to SSH to the bastion."
  default     = []
}
variable "bastion_public_ip" {
  type        = bool
  description = "Whether or not a public IP should be given to the bastion."
  default     = true
}
variable "bastion_image_name" {
  type        = string
  description = "The bastion image name"
  default     = "Oracle-Linux-7.7-2019.10.19-0"
}

# DNS
variable "create_dns" {
  type        = bool
  description = "Whether or not DNS forwarders and all of their resources (subnet/NSG/compute instance) should be created."
  default     = true
}
variable "dns_subnet" {
  type = object({
    cidr      = string,
    dns_label = string
  })
  description = "Options for the DNS subnet."
  default     = null
}
variable "existing_dns_forwarder_ips" {
  type        = list(string)
  description = "If DNS forwarders are not to be created, but existing ones used, provide these here."
  default     = null
}
variable "dns_namespace_mappings" {
  type = list(object({
    namespace = string
    server    = string
  }))
  description = "The DNS namespaces and servers that respond to these namespaces."
  default     = null
}
variable "reverse_dns_mappings" {
  type = list(object({
    cidr   = string
    server = string
  }))
  description = "The reverse DNS namespaces and servers that respond to these reverse namespaces."
  default     = null
}
variable "dns_forwarder_1" {
  type = object({
    ad         = number,
    private_ip = string
  })
  description = "Settings for DNS forwarder #1."
  default     = null
}
variable "dns_forwarder_2" {
  type = object({
    ad         = number,
    private_ip = string
  })
  description = "Settings for DNS forwarder #2."
  default     = null
}

# Ansible
variable "create_ansible" {
  type        = bool
  description = "Whether or not an Ansible control machine and all of its resources (subnet/NSG/compute instance) should be created."
  default     = true
}
variable "ansible_subnet" {
  type = object({
    cidr      = string,
    dns_label = string
  })
  description = "Options for the Ansible subnet."
  default     = null
}

# LB - public
variable "lb_pub_subnet" {
  type = object({
    cidr      = string,
    dns_label = string
  })
  description = "Options for the public LB subnet."
  default     = null
}
variable "lb_pub" {
  type = object({
    name         = string,
    shape        = string,
    cookie_name  = string,
    app_hostname = string,
    fm_hostname  = string
  })
  description = "Settings for the public LB."
}
variable "lb_pub_ssl_plm_as" {
  type = object({
    backends = object({
      ca_certificate          = string,
      passphrase              = string,
      private_key             = string,
      public_certificate      = string,
      verify_depth            = number,
      verify_peer_certificate = bool
    }),
    listener = object({
      ca_certificate          = string,
      passphrase              = string,
      private_key             = string,
      public_certificate      = string,
      verify_depth            = number,
      verify_peer_certificate = bool
    })
  })
}

variable "lb_pub_ssl_plm_fm" {
  type = object({
    backends = object({
      ca_certificate          = string,
      passphrase              = string,
      private_key             = string,
      public_certificate      = string,
      verify_depth            = number,
      verify_peer_certificate = bool
    }),
    listener = object({
      ca_certificate          = string,
      passphrase              = string,
      private_key             = string,
      public_certificate      = string,
      verify_depth            = number,
      verify_peer_certificate = bool
    })
  })
}

# LB - private
variable "lb_priv_subnet" {
  type = object({
    cidr      = string,
    dns_label = string
  })
  description = "Options for the private LB subnet."
  default     = null
}
variable "lb_priv" {
  type = object({
    name         = string,
    shape        = string,
    cookie_name  = string,
    app_hostname = string
  })
  description = "Settings for the private LB."
}

variable "lb_priv_ssl_plm_as" {
  type = object({
    backends = object({
      ca_certificate          = string,
      passphrase              = string,
      private_key             = string,
      public_certificate      = string,
      verify_depth            = number,
      verify_peer_certificate = bool
    }),
    listener = object({
      ca_certificate          = string,
      passphrase              = string,
      private_key             = string,
      public_certificate      = string,
      verify_depth            = number,
      verify_peer_certificate = bool
    })
  })
}

# LB - generic - Rule Set-specific variables
variable "rule_sets" {
  type = map(list(object({
    action = string,
    header = string,
    prefix = string,
    suffix = string,
    value  = string
  })))
  description = "Parameters for Rule Sets."
  default     = {}
}

# LB - generic - ports

# The load balancer listening port
variable "lb_port" {
  type        = number
  default     = 443
  description = "The load balancer listening port"
}

# The production port AS managed servers on a compute node.
variable "as_prod_port" {
  type        = number
  default     = 8001
  description = "The production port AS managed servers on a compute node."
}

# The admin port AS servers are listening on. The listening port for the AS WLS Admin Server.
variable "as_admin_port" {
  type        = number
  default     = 9001
  description = "The admin port AS servers are listening on. The listening port for the AS WLS Admin Server."
}

# Agile PLM file manager port
variable "file_mgr_port" {
  type        = number
  description = "Agile PLM file manager port"
  default     = "8080"
}

# DB

# To provision or not the DB layer for the agile plm
variable "provision_db" {
  type        = bool
  default     = false
  description = "To provision or not the DB layer for the agile plm"
}

variable "db_subnet" {
  type = object({
    cidr      = string,
    dns_label = string
  })
  description = "Options for the DB subnet."
  default     = null
}
variable "db_backup_subnet" {
  type = object({
    cidr      = string,
    dns_label = string
  })
  description = "Options for the DB backup subnet."
  default     = null
}

variable "db_options" {
  type = object({
    ad             = number,
    compartment_id = string,

    shape         = string,
    hostname      = string,
    ssh_auth_keys = list(string)
    disk_redund   = string,
    cluster_name  = string,
    license_model = string,
    node_cnt      = number,
    time_zone     = string,

    db_admin_password = string,
    db_size_tbs       = number,
    db_name           = string,
    db_edition        = string,
    db_char_set       = string,
    db_nchar_set      = string,
    db_workload       = string,
    db_pdb_name       = string,
    db_ver            = string,
    db_backup_days    = number,

    is_exacs             = bool,
    exacs_sparse_diskgrp = bool,

    bm_data_size_percent = number,
    bm_cpu_cores         = number,

    vm_data_size_gb = number
  })
  description = "The various options to customize the DB that is provisioned."
}


# app
variable "app_subnet" {
  type = object({
    cidr      = string,
    dns_label = string
  })
  description = "Options for the app subnet."
  default     = null
}



# files
variable "files_subnet" {
  type = object({
    cidr      = string,
    dns_label = string
  })
  description = "Options for the files subnet."
  default     = null
}

# network-related
variable "on_prem_cidrs" {
  type        = list(string)
  description = "The CIDRs of any non-OCI networks that will connect to this environment over FastConnect and/or VPN."
  default     = []
}

# load balancers

# To provision or not the private_lb for the agile plm
variable "provision_priv_lb" {
  type        = bool
  default     = false
  description = "To provision or not the private_lb for the agile plm"
}

# To provision or not the public_lb for the agile plm
variable "provision_pub_lb" {
  type        = bool
  default     = false
  description = "To provision or not the public_lb for the agile plm"
}

# PLM-specific
variable "plm_admin_cidrs" {
  type        = list(string)
  description = "The CIDRs that are allowed to access the PLM application servers."
  default     = []
}
variable "remote_file_manager_cidrs" {
  type        = list(string)
  description = "The CIDRs of remote file managers that the internal file manager servers are permitted to communicate with over HTTPS."
  default     = []
}

variable "plm_as_options" {
  type = object({
    num_inst          = number
    shape             = string
    boot_vol_size     = number
    ssh_auth_keys     = list(string)
    img_id            = string
    img_name          = string
    mkp_image_name    = string
    mkp_image_version = string
  })
  description = "The different parameters to customize the Agile PLM application servers."
  default     = null
}

# The aditional block volumes size
variable "as_aditional_block_volume_size" {
  type        = number
  default     = 50
  description = "The aditional block volumes size"
}

# The aditional as block volume mount point
variable "as_aditional_block_volume_mount_point" {
  type        = string
  default     = "/u01"
  description = "The aditional as block volume mount point"
}

# The aditional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze
variable "as_volumes_backup_policy" {
  type        = string
  default     = "Bronze"
  description = "The aditional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze"
}

# The aditional block volumes size
variable "fm_aditional_block_volume_size" {
  type        = number
  default     = 50
  description = "The aditional block volumes size"
}

# The aditional fm block volume mount point
variable "fm_aditional_block_volume_mount_point" {
  type        = string
  default     = "/u01"
  description = "The aditional fm block volume mount point"
}

# The aditional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze
variable "fm_volumes_backup_policy" {
  type        = string
  default     = "Bronze"
  description = "The aditional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze"
}

variable "plm_fm_options" {
  type = object({
    num_inst          = number
    shape             = string
    boot_vol_size     = number
    ssh_auth_keys     = list(string)
    img_id            = string
    img_name          = string
    mkp_image_name    = string
    mkp_image_version = string
  })
  description = "The different parameters to customize the Agile PLM file manager servers."
  default     = null
}

