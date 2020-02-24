# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  # INGRESS RULES
  nsg_i_rules_plm_admin = [for i in(var.plm_admin_cidrs != null ? var.plm_admin_cidrs : []) :
    {
      stateless   = false
      protocol    = "6"
      description = "Ingress whitelist for PLM admin"
      src         = i
      src_type    = "CIDR_BLOCK"
      src_port = {
        min = null
        max = null
      }
      dst_port = {
        min = var.lb_port
        max = var.lb_port
      }
      icmp_type = null
      icmp_code = null
    }
  ]
  nsg_i_rules_remote_fms = [for i in(var.remote_file_manager_cidrs != null ? var.remote_file_manager_cidrs : []) :
    {
      stateless   = false
      protocol    = "6"
      description = "Ingress flows for remote file manager CIDR ${i}."
      src         = i
      src_type    = "CIDR_BLOCK"
      src_port = {
        min = null
        max = null
      }
      dst_port = {
        min = var.lb_port
        max = var.lb_port
      }
      icmp_type = null
      icmp_code = null
    }
  ]

  # app server
  nsg_i_rules_app_server = var.plm_as_options.num_inst > 0 ? concat(
    local.nsg_i_rules_plm_admin,
    [
      # LB-specific rules
      {
        stateless   = false
        protocol    = "6"
        description = "Ingress Public LB (HTTPS) - Admin"
        src         = "lb_pub"
        src_type    = "NSG_NAME"
        src_port = {
          min = null
          max = null
        }
        dst_port = {
          min = var.as_admin_port
          max = var.as_admin_port
        }
        icmp_type = null
        icmp_code = null
      },
      {
        stateless   = false
        protocol    = "6"
        description = "Ingress Public LB (HTTPS) - Prod"
        src         = "lb_pub"
        src_type    = "NSG_NAME"
        src_port = {
          min = null
          max = null
        }
        dst_port = {
          min = var.as_prod_port
          max = var.as_prod_port
        }
        icmp_type = null
        icmp_code = null
      },
      {
        stateless   = false
        protocol    = "6"
        description = "Ingress Private LB (HTTPS) - Admin"
        src         = "lb_priv"
        src_type    = "NSG_NAME"
        src_port = {
          min = null
          max = null
        }
        dst_port = {
          min = var.as_admin_port
          max = var.as_admin_port
        }
        icmp_type = null
        icmp_code = null
      },
      {
        stateless   = false
        protocol    = "6"
        description = "Ingress Private LB (HTTPS) - prod"
        src         = "lb_priv"
        src_type    = "NSG_NAME"
        src_port = {
          min = null
          max = null
        }
        dst_port = {
          min = var.as_prod_port
          max = var.as_prod_port
        }
        icmp_type = null
        icmp_code = null
      },
      {
        stateless   = false
        protocol    = "6"
        description = "Ingress SSH from bastion"
        src         = local.bastion_subnet_cidr
        src_type    = "CIDR_BLOCK"
        src_port = {
          min = null
          max = null
        }
        dst_port = {
          min = 22
          max = 22
        }
        icmp_type = null
        icmp_code = null
      },
    ]
  ) : []

  # file manager
  nsg_i_rules_file_manager = var.plm_fm_options.num_inst > 0 ? concat(
    local.nsg_i_rules_remote_fms,
    [
      {
        stateless   = false
        protocol    = "6"
        description = "Ingress Public LB (HTTPS) - Prod"
        src         = "lb_pub"
        src_type    = "NSG_NAME"
        src_port = {
          min = null
          max = null
        }
        dst_port = {
          min = var.file_mgr_port
          max = var.file_mgr_port
        }
        icmp_type = null
        icmp_code = null
      },
      {
        stateless   = false
        protocol    = "6"
        description = "Ingress Private LB (HTTPS) - prod"
        src         = "lb_priv"
        src_type    = "NSG_NAME"
        src_port = {
          min = null
          max = null
        }
        dst_port = {
          min = var.file_mgr_port
          max = var.file_mgr_port
        }
        icmp_type = null
        icmp_code = null
      },
      {
        stateless   = false
        protocol    = "6"
        description = "Ingress SSH"
        src         = local.bastion_subnet_cidr
        src_type    = "CIDR_BLOCK"
        src_port = {
          min = null
          max = null
        }
        dst_port = {
          min = 22
          max = 22
        }
        icmp_type = null
        icmp_code = null
      }
    ]
  ) : []

  # public LB
  nsg_i_rules_lb_pub = var.provision_pub_lb == true ? [
    {
      stateless   = false
      description = "Ingress HTTPS (${var.lb_port}) - prod -  from public internet for as"
      protocol    = "6"
      src         = "0.0.0.0/0"
      src_type    = "CIDR_BLOCK"
      src_port = {
        min = null
        max = null
      }
      dst_port = {
        min = var.lb_port
        max = var.lb_port
      }
      icmp_code = null
      icmp_type = null
    }
  ] : []

  # private LB
  nsg_i_rules_lb_priv = var.provision_priv_lb == true ? [
    {
      stateless   = false
      description = "Ingress HTTPS (${var.lb_port}) for app server"
      protocol    = "6"
      src         = "0.0.0.0/0"
      src_type    = "CIDR_BLOCK"
      src_port = {
        min = null
        max = null
      }
      dst_port = {
        min = var.lb_port
        max = var.lb_port
      }
      icmp_code = null
      icmp_type = null
    }
  ] : []

  # DB
  nsg_i_rules_db = var.provision_db == true ? [
    {
      description = "Ingress Agile PLM application server instances"
      stateless   = false
      protocol    = "6"
      src         = "app_server"
      src_type    = "NSG_NAME"
      src_port = {
        min = null
        max = null
      }
      dst_port = {
        min = 1521
        max = 1521
      }
      icmp_code = null
      icmp_type = null
    },
    {
      stateless   = false
      protocol    = "6"
      description = "Ingress SSH"
      src         = local.bastion_subnet_cidr
      src_type    = "CIDR_BLOCK"
      src_port = {
        min = null
        max = null
      }
      dst_port = {
        min = 22
        max = 22
      }
      icmp_type = null
      icmp_code = null
    }
  ] : []

  # DB backup
  nsg_i_rules_db_backup = []


  # EGRESS RULES
  nsg_e_rules_remote_fms = [for i in(var.remote_file_manager_cidrs != null ? var.remote_file_manager_cidrs : []) :
    {
      stateless   = true
      protocol    = "6"
      description = "Ingress flows for remote file manager CIDR ${i}."
      src         = i
      src_type    = "CIDR_BLOCK"
      src_port = {
        min = null
        max = null
      }
      dst_port = {
        min = var.lb_port
        max = var.lb_port
      }
      icmp_type = null
      icmp_code = null
    }
  ]

  # app server
  nsg_e_rules_app_server = var.plm_as_options.num_inst > 0 ? [
    # all egress
    {
      stateless   = false
      protocol    = "6"
      description = "All Egress"
      dst         = "0.0.0.0/0"
      dst_type    = "CIDR_BLOCK"
      dst_port = {
        min = null
        max = null
      }
      src_port = {
        min = null
        max = null
      }
      icmp_type = null
      icmp_code = null
    },
  ] : []

  # file manager
  nsg_e_rules_file_manager = var.plm_fm_options.num_inst > 0 ? concat(
    local.nsg_e_rules_remote_fms,
    [
      {
        stateless   = false
        protocol    = "6"
        description = "Egress HTTPS to public LB."
        dst         = "0.0.0.0/0"
        dst_type    = "CIDR_BLOCK"
        src_port = {
          min = null
          max = null
        }
        dst_port = {
          min = null
          max = null
        }
        icmp_type = null
        icmp_code = null
      }
    ]
  ) : []

  # public LB
  nsg_e_rules_lb_pub = var.provision_pub_lb == true ? [
    {
      stateless   = false
      description = "Egress on all TCP ports to anywhere"
      protocol    = "6"
      dst         = "0.0.0.0/0"
      dst_type    = "CIDR_BLOCK"
      dst_port = {
        min = null
        max = null
      }
      src_port = {
        min = null
        max = null
      }
      icmp_code = null
      icmp_type = null
    }
  ] : []

  # private LB
  nsg_e_rules_lb_priv = var.provision_priv_lb == true ? [
    {
      description = "Egress HTTPS to Agile PLM application servers."
      stateless   = false
      protocol    = "6"
      dst         = "0.0.0.0/0"
      dst_type    = "CIDR_BLOCK"
      src_port = {
        min = null
        max = null
      }
      dst_port = {
        min = null
        max = null
      }
      icmp_code = null
      icmp_type = null
    }
  ] : []

  # DB
  nsg_e_rules_db = var.provision_db == true ? [
    {
      description = "Egress HTTP to file manager servers."
      stateless   = false
      protocol    = "6"
      dst         = "0.0.0.0/0"
      dst_type    = "CIDR_BLOCK"
      dst_port = {
        min = null
        max = null
      }
      src_port = {
        min = null
        max = null
      }
      icmp_code = null
      icmp_type = null
    }
  ] : []

  obj_stg_cidr = [for i in data.oci_core_services.this.services :
    i.cidr_block if length(regexall("^oci-.*-objectstorage", i.cidr_block)) > 0
  ][0]

  # DB backup
  nsg_e_rules_db_backup = [
    {
      description = "Egress HTTPS to OCI Object Storage."
      stateless   = false
      protocol    = "6"
      dst         = "0.0.0.0/0"
      dst_type    = "CIDR_BLOCK"
      dst_port = {
        min = null
        max = null
      }
      src_port = {
        min = null
        max = null
      }
      icmp_code = null
      icmp_type = null
    }
  ]

  ####
  nsgs_names = ["file_manager", "app_server", "db", "lb_pub", "lb_priv"]


  all_nsgs = {
    db = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [for i in local.nsg_i_rules_db :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          src         = i.src
          src_type    = i.src_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
      egress_rules = [for i in local.nsg_e_rules_db :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          dst         = i.dst
          dst_type    = i.dst_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
    }
    app_server = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [for i in local.nsg_i_rules_app_server :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          src         = i.src
          src_type    = i.src_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
      egress_rules = [for i in local.nsg_e_rules_app_server :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          dst         = i.dst
          dst_type    = i.dst_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
    }
    file_manager = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [for i in local.nsg_i_rules_file_manager :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          src         = i.src
          src_type    = i.src_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
      egress_rules = [for i in local.nsg_e_rules_file_manager :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          dst         = i.dst
          dst_type    = i.dst_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
    }
    lb_pub = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [for i in local.nsg_i_rules_lb_pub :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          src         = i.src
          src_type    = i.src_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
      egress_rules = [for i in local.nsg_e_rules_lb_pub :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          dst         = i.dst
          dst_type    = i.dst_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
    }
    lb_priv = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [for i in local.nsg_i_rules_lb_priv :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          src         = i.src
          src_type    = i.src_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
      egress_rules = [for i in local.nsg_e_rules_lb_priv :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          dst         = i.dst
          dst_type    = i.dst_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
    }
  }
  nsgs = {
    for nsgs_name in local.nsgs_names : nsgs_name => local.all_nsgs[nsgs_name] if(
      (nsgs_name == "file_manager" && var.plm_fm_options.num_inst > 0) ||
      (nsgs_name == "app_server" && var.plm_as_options.num_inst > 0) ||
      (nsgs_name == "db" && var.provision_db == true) ||
      (nsgs_name == "lb_pub" && var.provision_pub_lb == true) ||
      (nsgs_name == "lb_priv" && var.provision_priv_lb == true)
    )
  }
}

module "oci_network_security_policies" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-network-security.git?ref=v0.9.7"

  default_compartment_id = var.default_compartment_id
  default_defined_tags   = var.default_defined_tags
  default_freeform_tags  = var.default_freeform_tags
  vcn_id                 = module.ent_base.vcn.id
  nsgs                   = local.all_nsgs
}

# there's an issue with how merge calculates things, forcing us to use a separate module, rather than merging conditional maps together...
module "oci_network_security_policies_db_backup" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-network-security.git?ref=v0.9.7"

  default_compartment_id = var.default_compartment_id
  default_defined_tags   = var.default_defined_tags
  default_freeform_tags  = var.default_freeform_tags
  vcn_id                 = module.ent_base.vcn.id

  nsgs = local.is_exacs != true ? {} : {
    db_backup = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules = [for i in local.nsg_i_rules_db_backup :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          src         = i.src
          src_type    = i.src_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
      egress_rules = [for i in local.nsg_e_rules_db_backup :
        {
          description = i.description
          stateless   = i.stateless
          protocol    = i.protocol
          dst         = i.dst
          dst_type    = i.dst_type
          dst_port = i.dst_port.min == null && i.dst_port.max == null ? null : {
            min = i.dst_port.min
            max = i.dst_port.max
          }
          src_port = i.src_port.min == null && i.src_port.max == null ? null : {
            min = i.src_port.min
            max = i.src_port.max
          }
          icmp_code = i.icmp_code
          icmp_type = i.icmp_type
        }
      ]
    }
  }
}
