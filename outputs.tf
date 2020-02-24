# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# network-specific
output "vcn" {
  description = "VCN"
  value       = module.ent_base.vcn
}

output "igw" {
  description = "IGW"
  value       = module.ent_base.igw
}

output "svcgw" {
  description = "SVCGW"
  value       = module.ent_base.svcgw
}

output "svcgw_services" {
  description = "SVCGW Services"
  value       = module.ent_base.svcgw_services
}

output "natgw" {
  description = "NATGW"
  value       = module.ent_base.natgw
}

output "drg" {
  description = "DRG"
  value       = module.ent_base.drg
}

output "dhcp_options" {
  value = module.ent_base.dhcp_options
}

output "route_tables" {
  value = module.ent_base.route_tables
}

output "vcn_wide_sl" {
  value = module.ent_base.vcn_wide_sl
}

output "default_sl" {
  value = module.ent_base.default_sl
}

output "all_vcn_sl" {
  value = data.oci_core_security_lists.security_lists
}


output "nsgs" {
  value = module.oci_network_security_policies.nsgs
}

output "nsg_ingress_rules" {
  value = module.oci_network_security_policies.nsg_ingress_rules
}

output "nsg_egress_rules" {
  value = module.oci_network_security_policies.nsg_egress_rules
}

output "nsg_rules" {
  value = module.oci_network_security_policies.nsg_rules
}

output "all_agile_plm_subnets" {
  value = data.oci_core_subnets.agile_plm_subnets.subnets
}


# bastion-specific
output "bastion_subnet" {
  value       = module.ent_base.bastion_subnet
  description = "The bastion subnet that was created."
}

output "bastion_nsg" {
  value       = module.ent_base.bastion_nsg
  description = "The bastion NSG that was created."
}

output "bastion_nsg_rules" {
  value       = module.ent_base.bastion_nsg_rules
  description = "The bastion NSG Rules that have been created."
}

output "bastion_instance" {
  value       = module.ent_base.bastion_instance
  description = "The bastion compute instance that has been created."
}

output "bastion_priv_ip" {
  value       = module.ent_base.bastion_instance != null ? module.ent_base.bastion_instance.private_ip : null
  description = "The private IP of the bastion instance."
}

output "bastion_pub_ip" {
  value       = module.ent_base.bastion_instance != null ? module.ent_base.bastion_instance.public_ip : null
  description = "The public IP (if one is provisioned) of the bastion instance."
}

# DNS-specific
output "dns_cloud_init_data" {
  value = module.ent_base.dns_cloud_init_data
}

output "dns_instances" {
  value       = module.ent_base.dns_instances
  description = "The DNS compute instance(s) that have been created."
}

# ansible-specific
output "ansible_instance" {
  value       = module.ent_base.ansible_instance
  description = "The Ansible compute instance that has been created."
}

output "ansible_priv_ip" {
  value       = module.ent_base.ansible_instance != null ? module.ent_base.ansible_instance.private_ip : null
  description = "The private IP address of the Ansible control machine."
}

# DB-specific
output "db_is_exacs" {
  value       = var.provision_db == false ? null : local.is_exacs
  description = "Whether or not the DB is an ExaCS."
}

output "db" {
  value = var.provision_db == false ? null : flatten(concat(
    oci_database_db_system.this_not_exacs,
    oci_database_db_system.this_exacs
  ))[0]
  description = "The DB created to support this solution."
}

output "db_conn_strings" {
  value = var.provision_db == false ? null : flatten(concat(
    oci_database_db_system.this_not_exacs,
    oci_database_db_system.this_exacs
  ))[0].db_home[0].database[0].connection_strings
  description = "The connection strings for the DB."
}

# compute instances
output "plm_as_compute_instances" {
  value = module.oci_instances_as != null ? (module.oci_instances_as.instance != null ? (length(module.oci_instances_as.instance) > 0 ? module.oci_instances_as.instance : null) : null) : null
}

output "plm_as_compute_instances_agreements" {
  value = module.oci_instances_as != null ? module.oci_instances_as.oci_mkp_agreements : null
}

output "plm_fm_compute_instances" {
  value = module.oci_instances_fm != null ? (module.oci_instances_fm.instance != null ? (length(module.oci_instances_fm.instance) > 0 ? module.oci_instances_fm.instance : null) : null) : null
}

output "plm_fm_compute_instances_agreements" {
  value = module.oci_instances_fm != null ? module.oci_instances_fm.oci_mkp_agreements : null
}

# load balancers
output "plm_public_lb" {
  value = module.lb_pub.lb
}

output "plm_private_lb" {
  value = module.lb_priv.lb
}

output "plm_public_backend_sets" {
  value = module.lb_pub.backend_sets
}

output "plm_private_backend_sets" {
  value = module.lb_priv.backend_sets
}

output "plm_public_backends" {
  value = module.lb_pub.backends
}

output "plm_private_backends" {
  value = module.lb_priv.backends
}

output "plm_public_listeners" {
  value = module.lb_pub.listeners
}

output "plm_private_listeners" {
  value = module.lb_priv.listeners
}

output "plm_public_path_route_sets" {
  value = module.lb_pub.path_route_sets
}

output "plm_private_path_route_sets" {
  value = module.lb_priv.path_route_sets
}

#########################
## Block Volumes
#########################
output "as_block_volumes" {
  description = "The list of block volume ocids"
  value       = module.as_block_storage.vols
}

output "fm_block_volumes" {
  description = "The list of block volume ocids"
  value       = module.fm_block_storage.vols
}
