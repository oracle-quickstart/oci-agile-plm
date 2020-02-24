# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  backends_plm_as_admin = ((var.provision_pub_lb == false && var.provision_priv_lb == false) || local.plm_as_options.num_inst == 0) ? {} : {
    for i in range(local.plm_as_options.num_inst) :
    "plm_as_${i + 1}_${var.as_admin_port}" => {
      ip      = length(module.oci_instances_as.instance) > 0 ? module.oci_instances_as.instance["plm_as_${i + 1}"].private_ip : null
      port    = var.as_admin_port
      backup  = false
      drain   = false
      offline = false
      weight  = 1
    }
  }

  # rule_sets 
  rule_sets = {
    for k, v in(var.rule_sets != null ? var.rule_sets : {}) : k => v
  }
  rule_sets_keys = keys(local.rule_sets)

  /*
  backends_plm_as_prod = ((var.provision_pub_lb == false && var.provision_priv_lb == false) || local.plm_as_options.num_inst == 0) ? {} : {
    for i in range(local.plm_as_options.num_inst * 2) :
    "plm_as_${(floor(i / 2) + 1)}_${i % 2 == 0 ? var.as_prod_port_01 : var.as_prod_port_02}" => {
      ip      = length(module.oci_instances_as.instance) > 0 ? module.oci_instances_as.instance["plm_as_${(floor(i / 2) + 1)}"].private_ip : null
      port    = i % 2 == 0 ? var.as_prod_port_01 : var.as_prod_port_02
      backup  = false
      drain   = false
      offline = false
      weight  = 1
    }
  }*/

  backends_plm_as_prod = ((var.provision_pub_lb == false && var.provision_priv_lb == false) || local.plm_as_options.num_inst == 0) ? {} : {
    for i in range(local.plm_as_options.num_inst) :
    "plm_as_${i + 1}_${var.as_prod_port}" => {
      ip      = length(module.oci_instances_as.instance) > 0 ? module.oci_instances_as.instance["plm_as_${i + 1}"].private_ip : null
      port    = var.as_prod_port
      backup  = false
      drain   = false
      offline = false
      weight  = 1
    }
  }

  backends_plm_fm_prod = ((var.provision_pub_lb == false && var.provision_priv_lb == false) || var.plm_fm_options.num_inst == 0) ? {} : {
    for i in range(var.plm_fm_options.num_inst) :
    "plm_fm_${i + 1}_${var.file_mgr_port}" => {
      ip      = length(module.oci_instances_as.instance) > 0 ? module.oci_instances_fm.instance["plm_fm_${i + 1}"].private_ip : null
      port    = var.file_mgr_port
      backup  = false
      drain   = false
      offline = false
      weight  = 1
    }
  }

  lb_pub_defaults = {
    name         = "lb_pub"
    shape        = "100Mbps"
    cookie_name  = "plm_lbpub"
    app_hostname = "as"
    fm_hostname  = "fm"
  }
}

locals {
  all_backend_sets = {
    plm_as_prod = {
      policy             = "ROUND_ROBIN"
      health_check_name  = "plm_as_prod_health"
      enable_persistency = true
      enable_ssl         = true

      cookie_name             = "plm_as_prod"
      disable_fallback        = false
      certificate_name        = "plm_as_backends"
      verify_depth            = var.lb_pub_ssl_plm_as.backends.verify_depth
      verify_peer_certificate = var.lb_pub_ssl_plm_as.backends.verify_peer_certificate

      backends = local.backends_plm_as_prod
    },
    plm_as_admin = {
      policy             = "ROUND_ROBIN"
      health_check_name  = "plm_as_admin_health"
      enable_persistency = true
      enable_ssl         = true

      cookie_name             = "plm_as_admin"
      disable_fallback        = false
      certificate_name        = "plm_as_backends"
      verify_depth            = var.lb_pub_ssl_plm_as.backends.verify_depth
      verify_peer_certificate = var.lb_pub_ssl_plm_as.backends.verify_peer_certificate

      backends = local.backends_plm_as_admin
    },
    plm_fm_prod = {
      policy             = "ROUND_ROBIN"
      health_check_name  = "plm_fm_prod_health"
      enable_persistency = true
      enable_ssl         = true

      cookie_name             = "plm_fm_prod"
      disable_fallback        = false
      certificate_name        = "plm_fm_backends"
      verify_depth            = var.lb_pub_ssl_plm_fm.backends.verify_depth
      verify_peer_certificate = var.lb_pub_ssl_plm_fm.backends.verify_peer_certificate

      backends = local.backends_plm_fm_prod
    }
  }

  all_listeners = {
    plm_pub_listener = {
      default_backend_set_name = "plm_as_prod"
      port                     = var.lb_port
      protocol                 = "HTTP"
      idle_timeout             = 180
      hostnames                = [var.lb_pub.app_hostname]
      path_route_set_name      = null
      rule_set_names           = local.rule_sets_keys
      enable_ssl               = true
      certificate_name         = "plm_as_listener"
      verify_depth             = var.lb_pub_ssl_plm_as.listener.verify_depth
      verify_peer_certificate  = var.lb_pub_ssl_plm_as.listener.verify_peer_certificate
    },
    plm_priv_listener = {
      default_backend_set_name = "plm_as_prod"
      port                     = var.lb_port
      protocol                 = "HTTP"
      idle_timeout             = 180
      hostnames                = [var.lb_priv.app_hostname]
      path_route_set_name      = null
      rule_set_names           = local.rule_sets_keys
      enable_ssl               = true
      certificate_name         = "plm_as_listener"
      verify_depth             = var.lb_priv_ssl_plm_as.listener.verify_depth
      verify_peer_certificate  = var.lb_priv_ssl_plm_as.listener.verify_peer_certificate
    }
  }
  backendsets_names = ["plm_as_prod", "plm_as_admin", "plm_fm_prod"]

  backend_sets = {
    for bkd_set_name in local.backendsets_names : bkd_set_name => local.all_backend_sets[bkd_set_name] if(
      (bkd_set_name == "plm_as_prod") && (var.plm_as_options.num_inst > 0) ||
      (bkd_set_name == "plm_as_admin") && (var.plm_as_options.num_inst > 0) ||
      (bkd_set_name == "plm_fm_prod") && (var.plm_fm_options.num_inst > 0)
    )
  }

  listeners_names = ["plm_priv_listener", "plm_pub_listener"]

  listeners_priv = {
    for listener_name in local.listeners_names : listener_name => local.all_listeners[listener_name] if(
      (listener_name == "plm_priv_listener") && (var.plm_as_options.num_inst > 0)
    )
  }

  listeners_pub = {
    for listener_name in local.listeners_names : listener_name => local.all_listeners[listener_name] if(
      (listener_name == "plm_pub_listener") && (var.plm_as_options.num_inst > 0)
    )
  }

  all_path_route_sets = {
    agile_plm_routes = [
      {
        backend_set_name = "plm_as_prod"
        path             = "/"
        match_type       = "PREFIX_MATCH"
      },
      {
        backend_set_name = "plm_as_admin"
        path             = "/as_console"
        match_type       = "PREFIX_MATCH"
      },
      {
        backend_set_name = "plm_fm_prod"
        path             = "/fm"
        match_type       = "PREFIX_MATCH"
      }
    ]
  }

  agile_plm_routes = [
    for agile_plm_route in local.all_path_route_sets.agile_plm_routes : agile_plm_route if(
      (agile_plm_route.backend_set_name == "plm_as_prod") && (var.plm_as_options.num_inst > 0) ||
      (agile_plm_route.backend_set_name == "plm_fm_prod") && (var.plm_fm_options.num_inst > 0)
    )
  ]

  path_route_sets = { "agile_plm_routes" = local.agile_plm_routes }
}

module "lb_pub" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-lb.git?ref=v0.9.2"

  default_compartment_id = var.default_compartment_id

  lb_options = (var.provision_pub_lb == false && var.plm_as_options.num_inst > 0) ? null : {
    display_name   = var.lb_pub != null ? (var.lb_pub.name != null ? var.lb_pub.name : local.lb_pub_defaults.name) : local.lb_pub_defaults.name
    compartment_id = null
    shape          = var.lb_pub != null ? (var.lb_pub.shape != null ? var.lb_pub.shape : local.lb_pub_defaults.shape) : local.lb_pub_defaults.shape
    subnet_ids     = [module.oci_subnets.subnets != null ? module.oci_subnets.subnets.lb_pub.id : null]
    private        = false
    nsg_ids        = [length(module.oci_network_security_policies.nsgs) > 0 ? module.oci_network_security_policies.nsgs.lb_pub.id : null]
    defined_tags   = null
    freeform_tags  = null
  }

  health_checks = {
    plm_as_admin_health = {
      protocol            = "HTTP"
      interval_ms         = 1000
      port                = var.as_admin_port
      response_body_regex = ".*"
      retries             = 3
      return_code         = 200
      timeout_in_millis   = 3000
      url_path            = "/"
    },
    plm_as_prod_health = {
      protocol            = "HTTP"
      interval_ms         = 1000
      port                = var.as_prod_port
      response_body_regex = ".*"
      retries             = 3
      return_code         = 200
      timeout_in_millis   = 3000
      url_path            = "/"
    },
    plm_fm_prod_health = {
      protocol            = "HTTP"
      interval_ms         = 1000
      port                = var.file_mgr_port
      response_body_regex = ".*"
      retries             = 3
      return_code         = 200
      timeout_in_millis   = 3000
      url_path            = "/"
    }
  }

  certificates = (var.provision_pub_lb == false && var.plm_as_options.num_inst > 0) ? {} : {
    plm_as_backends = {
      ca_certificate     = var.lb_pub_ssl_plm_as.backends.ca_certificate
      passphrase         = var.lb_pub_ssl_plm_as.backends.passphrase
      private_key        = var.lb_pub_ssl_plm_as.backends.private_key
      public_certificate = var.lb_pub_ssl_plm_as.backends.public_certificate
    },
    plm_as_listener = {
      ca_certificate     = var.lb_pub_ssl_plm_as.listener.ca_certificate
      passphrase         = var.lb_pub_ssl_plm_as.listener.passphrase
      private_key        = var.lb_pub_ssl_plm_as.listener.private_key
      public_certificate = var.lb_pub_ssl_plm_as.listener.public_certificate
    },
    plm_fm_backends = {
      ca_certificate     = var.lb_pub_ssl_plm_fm.backends.ca_certificate
      passphrase         = var.lb_pub_ssl_plm_fm.backends.passphrase
      private_key        = var.lb_pub_ssl_plm_fm.backends.private_key
      public_certificate = var.lb_pub_ssl_plm_fm.backends.public_certificate
    },
    plm_fm_listener = {
      ca_certificate     = var.lb_pub_ssl_plm_fm.listener.ca_certificate
      passphrase         = var.lb_pub_ssl_plm_fm.listener.passphrase
      private_key        = var.lb_pub_ssl_plm_fm.listener.private_key
      public_certificate = var.lb_pub_ssl_plm_fm.listener.public_certificate
    }
  }

  backend_sets = (var.provision_pub_lb == false && var.plm_as_options.num_inst > 0) ? {} : local.backend_sets

  listeners = (var.provision_pub_lb == false && var.plm_as_options.num_inst > 0) ? {} : local.listeners_pub

  path_route_sets = (var.provision_pub_lb == false && var.plm_as_options.num_inst > 0) ? {} : local.path_route_sets

  rule_sets = local.rule_sets
}

locals {
  lb_priv_defaults = {
    name        = "lb_priv"
    shape       = "100Mbps"
    cookie_name = "plm_lbpriv"
    fm_hostname = "fm"
  }
}

module "lb_priv" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-lb.git?ref=v0.9.2"

  default_compartment_id = var.default_compartment_id

  lb_options = var.provision_priv_lb == false ? null : {
    display_name   = var.lb_priv != null ? (var.lb_priv.name != null ? var.lb_priv.name : local.lb_priv_defaults.name) : local.lb_priv_defaults.name
    compartment_id = null
    shape          = var.lb_priv != null ? (var.lb_priv.shape != null ? var.lb_priv.shape : local.lb_priv_defaults.shape) : local.lb_priv_defaults.shape
    subnet_ids     = [module.oci_subnets.subnets != null ? module.oci_subnets.subnets.lb_priv.id : null]
    private        = true
    nsg_ids        = [length(module.oci_network_security_policies.nsgs) > 0 ? module.oci_network_security_policies.nsgs.lb_priv.id : null]
    defined_tags   = null
    freeform_tags  = null
  }

  health_checks = {
    plm_as_admin_health = {
      protocol            = "HTTP"
      interval_ms         = 1000
      port                = var.as_admin_port
      response_body_regex = ".*"
      retries             = 3
      return_code         = 200
      timeout_in_millis   = 3000
      url_path            = "/"
    },
    plm_as_prod_health = {
      protocol            = "HTTP"
      interval_ms         = 1000
      port                = var.as_prod_port
      response_body_regex = ".*"
      retries             = 3
      return_code         = 200
      timeout_in_millis   = 3000
      url_path            = "/"
    },
    plm_fm_prod_health = {
      protocol            = "HTTP"
      interval_ms         = 1000
      port                = var.file_mgr_port
      response_body_regex = ".*"
      retries             = 3
      return_code         = 200
      timeout_in_millis   = 3000
      url_path            = "/"
    }
  }

  certificates = (var.provision_priv_lb == false && var.plm_as_options.num_inst > 0) ? {} : {
    plm_as_backends = {
      ca_certificate     = var.lb_pub_ssl_plm_as.backends.ca_certificate
      passphrase         = var.lb_pub_ssl_plm_as.backends.passphrase
      private_key        = var.lb_pub_ssl_plm_as.backends.private_key
      public_certificate = var.lb_pub_ssl_plm_as.backends.public_certificate
    },
    plm_as_listener = {
      ca_certificate     = var.lb_pub_ssl_plm_as.listener.ca_certificate
      passphrase         = var.lb_pub_ssl_plm_as.listener.passphrase
      private_key        = var.lb_pub_ssl_plm_as.listener.private_key
      public_certificate = var.lb_pub_ssl_plm_as.listener.public_certificate
    },
    plm_fm_backends = {
      ca_certificate     = var.lb_pub_ssl_plm_fm.backends.ca_certificate
      passphrase         = var.lb_pub_ssl_plm_fm.backends.passphrase
      private_key        = var.lb_pub_ssl_plm_fm.backends.private_key
      public_certificate = var.lb_pub_ssl_plm_fm.backends.public_certificate
    },
    plm_fm_listener = {
      ca_certificate     = var.lb_pub_ssl_plm_fm.listener.ca_certificate
      passphrase         = var.lb_pub_ssl_plm_fm.listener.passphrase
      private_key        = var.lb_pub_ssl_plm_fm.listener.private_key
      public_certificate = var.lb_pub_ssl_plm_fm.listener.public_certificate
    }
  }

  backend_sets = (var.provision_priv_lb == false && var.plm_as_options.num_inst > 0) ? {} : local.backend_sets

  listeners = (var.provision_priv_lb == false && var.plm_as_options.num_inst > 0) ? {} : local.listeners_priv

  path_route_sets = (var.provision_priv_lb == false && var.plm_as_options.num_inst > 0) ? {} : local.path_route_sets

  rule_sets = (var.provision_priv_lb == false && var.plm_as_options.num_inst > 0) ? {} : local.rule_sets
}
