# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {

  #########################
  ## Networking Details
  #########################
  networking_details = {
    vcn = {
      vcn_id          = module.agile_plm.bastion_subnet.vcn_id,
      vcn_name        = data.oci_core_vcn.vcn.display_name,
      vcn_cidr        = data.oci_core_vcn.vcn.cidr_block,
      vcn_dns_lable   = data.oci_core_vcn.vcn.dns_label,
      vcn_domain_name = data.oci_core_vcn.vcn.vcn_domain_name,
    },
    subnets = {
      for subnet in module.agile_plm.all_agile_plm_subnets : subnet.display_name => {
        ad            = subnet.availability_domain,
        defined_tags  = subnet.defined_tags,
        freeform_tags = subnet.freeform_tags,
        dhcp_options = {
          for dhcp in module.agile_plm.dhcp_options : dhcp.display_name => {
            state           = dhcp.state,
            options         = dhcp.options,
            dhcp_options_id = subnet.dhcp_options_id
          } if dhcp.id == subnet.dhcp_options_id
        },
        route_table = {
          for rt_table in module.agile_plm.route_tables : rt_table.display_name => {
            name           = rt_table.display_name,
            route_rules    = rt_table.route_rules,
            state          = rt_table.state,
            route_table_id = subnet.route_table_id
          } if rt_table.id == subnet.route_table_id
        },
        security_list = {
          for default_sec_list in module.agile_plm.all_vcn_sl["search"].security_lists : default_sec_list.display_name => {
            security_list_id       = default_sec_list.id,
            egress_security_rules  = default_sec_list.egress_security_rules,
            ingress_security_rules = default_sec_list.ingress_security_rules
          } if default_sec_list.id == data.oci_core_vcn.vcn.default_security_list_id
        },
        state = subnet.state,
        vcn = {
          vcn_id          = subnet.vcn_id,
          vcn_name        = data.oci_core_vcn.vcn.display_name,
          vcn_cidr        = data.oci_core_vcn.vcn.cidr_block,
          vcn_dns_lable   = data.oci_core_vcn.vcn.dns_label,
          vcn_domain_name = data.oci_core_vcn.vcn.vcn_domain_name,
        },
        name               = subnet.display_name,
        cidr_block         = subnet.cidr_block,
        dns_label          = subnet.dns_label,
        public_subnet      = ! (subnet.prohibit_public_ip_on_vnic),
        subnet_domain_name = subnet.subnet_domain_name,
        virtual_router_ip  = subnet.virtual_router_ip
      }

    },
    nsgs = merge({
      for nsg in module.agile_plm.nsgs : nsg.display_name => {
        name   = nsg.display_name,
        nsg_id = nsg.id,
        state  = nsg.state,
        nsg_rules = [
          for nsg_rule in module.agile_plm.nsg_rules : {
            description      = nsg_rule.description,
            direction        = nsg_rule.direction,
            destination_type = nsg_rule.destination_type,
            destination      = nsg_rule.destination,
            icmp_options     = nsg_rule.icmp_options,
            is_valid         = nsg_rule.is_valid,
            protocol         = nsg_rule.protocol,
            source           = nsg_rule.source,
            source_type      = nsg_rule.source_type,
            stateless        = nsg_rule.stateless,
            tcp_options      = nsg_rule.tcp_options,
            udp_options      = nsg_rule.udp_options
          } if nsg.id == nsg_rule.network_security_group_id
        ]
      }
      },
      {
        "${module.agile_plm.bastion_nsg.display_name}" = {
          name   = module.agile_plm.bastion_nsg.display_name,
          nsg_id = module.agile_plm.bastion_nsg.id,
          state  = module.agile_plm.bastion_nsg.state,
          nsg_rules = [
            for nsg_rule in module.agile_plm.bastion_nsg_rules : {
              description      = nsg_rule.description,
              direction        = nsg_rule.direction,
              destination_type = nsg_rule.destination_type,
              destination      = nsg_rule.destination,
              icmp_options     = nsg_rule.icmp_options,
              is_valid         = nsg_rule.is_valid,
              protocol         = nsg_rule.protocol,
              source           = nsg_rule.source,
              source_type      = nsg_rule.source_type,
              stateless        = nsg_rule.stateless,
              tcp_options      = nsg_rule.tcp_options,
              udp_options      = nsg_rule.udp_options
            } if module.agile_plm.bastion_nsg.id == nsg_rule.network_security_group_id
          ]
        }
      }
    ),
    igw = {
      "${module.agile_plm.igw.display_name}" = {
        display_name = module.agile_plm.igw.display_name,
        enabled      = module.agile_plm.igw.enabled
        id           = module.agile_plm.igw.id
        state        = module.agile_plm.igw.state
      }
    },
    svcgw          = module.agile_plm.svcgw,
    svcgw_services = module.agile_plm.svcgw_services,
    natgw = {
      block_traffic = module.agile_plm.natgw.block_traffic,
      display_name  = module.agile_plm.natgw.display_name
      id            = module.agile_plm.natgw.id
      nat_ip        = module.agile_plm.natgw.nat_ip
      state         = module.agile_plm.natgw.state
    }
    drg = {
      display_name = module.agile_plm.drg.drg.display_name
      id           = module.agile_plm.drg.drg.id
      state        = module.agile_plm.drg.drg.state
      drg_attachment = {
        display_name = module.agile_plm.drg.drg_attachment.display_name
        drg_id       = module.agile_plm.drg.drg_attachment.drg_id
        id           = module.agile_plm.drg.drg_attachment.id
        state        = module.agile_plm.drg.drg_attachment.state
      }
    }
  }

  #########################
  ## Instances
  #########################
  instances = merge(
    {
      "${module.agile_plm.bastion_instance.display_name}" = module.agile_plm.bastion_instance != null ? {
        name         = module.agile_plm.bastion_instance.display_name,
        ad           = module.agile_plm.bastion_instance.availability_domain,
        fault_domain = module.agile_plm.bastion_instance.fault_domain,
        private_ip   = module.agile_plm.bastion_instance.private_ip,
        public_ip    = module.agile_plm.bastion_instance.public_ip,
        shape        = module.agile_plm.bastion_instance.shape
      } : {}
    },
    module.agile_plm.dns_instances != null ? {
      for dns_inst in module.agile_plm.dns_instances : dns_inst.display_name => {
        name         = dns_inst.display_name,
        ad           = dns_inst.availability_domain,
        fault_domain = dns_inst.fault_domain,
        private_ip   = dns_inst.private_ip,
        public_ip    = dns_inst.public_ip,
        shape        = dns_inst.shape
      }
    } : {},
    module.agile_plm.plm_as_compute_instances != null ? {
      for as_inst in module.agile_plm.plm_as_compute_instances : as_inst.display_name => {
        name         = as_inst.display_name,
        ad           = as_inst.availability_domain,
        fault_domain = as_inst.fault_domain,
        private_ip   = as_inst.private_ip,
        public_ip    = as_inst.public_ip,
        shape        = as_inst.shape,
        mkp_image    = (var.default_img_name == null && var.default_img_id == null) ? module.agile_plm.plm_as_compute_instances_agreements[as_inst.display_name] : null

      }
    } : {},
    module.agile_plm.plm_fm_compute_instances != null ? {
      for fm_inst in module.agile_plm.plm_fm_compute_instances : fm_inst.display_name => {
        name         = fm_inst.display_name,
        ad           = fm_inst.availability_domain,
        fault_domain = fm_inst.fault_domain,
        private_ip   = fm_inst.private_ip,
        public_ip    = fm_inst.public_ip,
        shape        = fm_inst.shape,
        mkp_image    = (var.default_img_name == null && var.default_img_id == null) ? module.agile_plm.plm_fm_compute_instances_agreements[fm_inst.display_name] : null
      }
    } : {}
  )

  #########################
  ## Volumes Details
  #########################
  volumes = {
    block_volumes = merge({
      for x in module.agile_plm.as_block_volumes : x.display_name => {
        id            = x.id
        name          = x.display_name,
        ad            = x.availability_domain,
        size_in_gbs   = x.size_in_gbs,
        backup_policy = [for bkp in data.oci_core_volume_backup_policies.volume_backup_policies.volume_backup_policies : bkp.display_name if bkp.id == x.backup_policy_id][0]
      }
      },
      {
        for x in module.agile_plm.fm_block_volumes : x.display_name => {
          id            = x.id
          name          = x.display_name,
          ad            = x.availability_domain,
          size_in_gbs   = x.size_in_gbs,
          backup_policy = [for bkp in data.oci_core_volume_backup_policies.volume_backup_policies.volume_backup_policies : bkp.display_name if bkp.id == x.backup_policy_id][0]
        }
    })
  }

  #########################
  ## Database
  #########################
  database = module.agile_plm.db != null ? {
    "${module.agile_plm.db.display_name}" = {
      ad                      = module.agile_plm.db.availability_domain,
      cluster_name            = module.agile_plm.db.cluster_name,
      cpu_core_count          = module.agile_plm.db.cpu_core_count,
      data_storage_percentage = module.agile_plm.db.data_storage_percentage,
      data_storage_size_in_gb = module.agile_plm.db.data_storage_size_in_gb,
      database_edition        = module.agile_plm.db.database_edition,
      character_set           = module.agile_plm.db.db_home[0].database[0].character_set
      all_connection_strings  = module.agile_plm.db.db_home[0].database[0].connection_strings[0].all_connection_strings
      db_name                 = module.agile_plm.db.db_home[0].database[0].db_name,
      db_unique_name          = module.agile_plm.db.db_home[0].database[0].db_unique_name,
      db_workload             = module.agile_plm.db.db_home[0].database[0].db_workload,
      db_id                   = module.agile_plm.db.db_home[0].database[0].id,
      ncharacter_set          = module.agile_plm.db.db_home[0].database[0].ncharacter_set,
      pdb_name                = module.agile_plm.db.db_home[0].database[0].pdb_name
      state                   = module.agile_plm.db.db_home[0].database[0].state
      db_version              = module.agile_plm.db.db_home[0].db_version
      db_display_name         = module.agile_plm.db.db_home[0].display_name
      db_home_id              = module.agile_plm.db.db_home[0].id
      storage_management      = module.agile_plm.db.db_system_options[0].storage_management
      disk_redundancy         = module.agile_plm.db.disk_redundancy
      domain                  = module.agile_plm.db.domain
      fault_domains           = module.agile_plm.db.fault_domains
      listener_port           = module.agile_plm.db.listener_port
      node_count              = module.agile_plm.db.node_count
      reco_storage_size_in_gb = module.agile_plm.db.reco_storage_size_in_gb
      shape                   = module.agile_plm.db.shape
      is_ExaCS                = module.agile_plm.db_is_exacs
    }
  } : null

  #########################
  ## Load Balancers
  #########################
  load_balancers = merge(length(module.agile_plm.plm_public_lb) > 0 ? {
    "${module.agile_plm.plm_public_lb[0].display_name}" = {
      display_name       = module.agile_plm.plm_public_lb[0].display_name,
      id                 = module.agile_plm.plm_public_lb[0].id,
      ip_address_details = module.agile_plm.plm_public_lb[0].ip_address_details,
      ip_addresses       = module.agile_plm.plm_public_lb[0].ip_addresses,
      is_private         = module.agile_plm.plm_public_lb[0].is_private,
      shape              = module.agile_plm.plm_public_lb[0].shape,
      state              = module.agile_plm.plm_public_lb[0].state,
      plm_public_backend_sets = {
        for bes in module.agile_plm.plm_public_backend_sets : bes.name => {
          name                              = bes.name,
          policy                            = bes.policy,
          backend                           = bes.backend
          session_persistence_configuration = bes.session_persistence_configuration
          certificate_name                  = bes.ssl_configuration[0].certificate_name
          state                             = bes.state
        }
      },
      listeners = {
        for lsnr in module.agile_plm.plm_public_listeners : lsnr.name => {
          name                     = lsnr.name,
          port                     = lsnr.port,
          protocol                 = lsnr.protocol,
          hostnames                = lsnr.hostnames,
          default_backend_set_name = lsnr.default_backend_set_name
        }
      },
      path_route_sets = {
        for prs in module.agile_plm.plm_public_path_route_sets : prs.name => {
          name = prs.name,
          path_routes = [
            for pr in prs.path_routes : {
              backend_set_name = pr.backend_set_name,
              path             = pr.path,
              path_match_type  = pr.path_match_type[0].match_type
            }
          ]
        }
      }
    }
    } : {},
    length(module.agile_plm.plm_private_lb) > 0 ? {
      "${module.agile_plm.plm_private_lb[0].display_name}" = {
        display_name       = module.agile_plm.plm_private_lb[0].display_name,
        id                 = module.agile_plm.plm_private_lb[0].id,
        ip_address_details = module.agile_plm.plm_private_lb[0].ip_address_details,
        ip_addresses       = module.agile_plm.plm_private_lb[0].ip_addresses,
        is_private         = module.agile_plm.plm_private_lb[0].is_private,
        shape              = module.agile_plm.plm_private_lb[0].shape,
        state              = module.agile_plm.plm_private_lb[0].state,
        plm_private_backend_sets = {
          for bes in module.agile_plm.plm_private_backend_sets : bes.name => {
            name                              = bes.name,
            policy                            = bes.policy,
            backend                           = bes.backend
            session_persistence_configuration = bes.session_persistence_configuration
            certificate_name                  = bes.ssl_configuration[0].certificate_name
            state                             = bes.state
          }
        },
        listeners = {
          for lsnr in module.agile_plm.plm_private_listeners : lsnr.name => {
            name                     = lsnr.name,
            port                     = lsnr.port,
            protocol                 = lsnr.protocol,
            hostnames                = lsnr.hostnames,
            default_backend_set_name = lsnr.default_backend_set_name
          }
        },
        path_route_sets = {
          for prs in module.agile_plm.plm_private_path_route_sets : prs.name => {
            name = prs.name,
            path_routes = [
              for pr in prs.path_routes : {
                backend_set_name = pr.backend_set_name,
                path             = pr.path,
                path_match_type  = pr.path_match_type[0].match_type
              }
            ]
          }
        }
      }
  } : {})
}


###############################################
## OCI Agile PLM Complex - provisioning details
###############################################

output "oci_agile_plm_complex_details" {
  description = "OCI Agile PLM Complex - provisioning details"
  value = {
    networking_details = local.networking_details,
    volumes            = local.volumes,
    instances          = local.instances,
    database           = local.database,
    load_balancers     = local.load_balancers
  }
}

data "oci_core_vcn" "vcn" {
  #Required
  vcn_id = module.agile_plm.vcn.id
}

data "oci_core_volume_backup_policies" "volume_backup_policies" {
}
