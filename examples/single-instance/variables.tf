# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



##################################
# Tenancy authentication details
##################################

variable "tenancy_id" {}
variable "user_id" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

##################################
# Common config
##################################

# Default Compartment id
variable "default_compartment_id" {
  type        = string
  description = "Default Compartment id"
}

# A list of ssh public keys to be loaded on the provisioned Agile PLM instances
variable "default_ssh_auth_keys" {
  type        = list
  description = "A list of ssh public keys to be loaded on the provisioned Agile PLM instances"
}

# Compute instances ssh private key
variable "ssh_private_key_path" {
  type        = string
  description = "Compute instances ssh public key"
}

# The generic OCI image ocid to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible. See https://docs.cloud.oracle.com/iaas/images/ for a listing of OCI-provided image OCIDs
variable "default_img_id" {
  type        = string
  description = "The generic OCI image ocid to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible. See https://docs.cloud.oracle.com/iaas/images/ for a listing of OCI-provided image OCIDs"
}

# The generic OCI image name to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible.
variable "default_img_name" {
  type        = string
  description = "The generic OCI image name to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible."
}

# The generic OCI mkt image name to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible. Youl also need to provide the OCI MKT image ocid as default_image_id. Image name and version must both be provided toghether or must both be null. They have the lowest priority in determining whio will be the image to be used, after the source_id with priority 1 and image_name with priority 2
variable "default_mkp_image_name" {
  type        = string
  description = "The generic OCI mkt image name to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible. Youl also need to provide the OCI MKT image ocid as default_image_id. Image name and version must both be provided toghether or must both be null. They have the lowest priority in determining whio will be the image to be used, after the source_id with priority 1 and image_name with priority 2."
}

# The generic OCI mkt image version to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible. Youl also need to provide the OCI MKT image ocid as default_image_id.Image name and version must both be provided toghether or must both be null. They have the lowest priority in determining whio will be the image to be used, after the source_id with priority 1 and image_name with priority 2
variable "default_mkp_image_version" {
  type        = string
  description = "The generic OCI mkt image version to be used across all provisioned Agile PLM instances(as and fm), except: DBCS, bastion, DNS and ansible. Youl also need to provide the OCI MKT image ocid as default_image_id.Image name and version must both be provided toghether or must both be null. They have the lowest priority in determining whio will be the image to be used, after the source_id with priority 1 and image_name with priority 2."
}

##################################
# Database config
##################################

# To provision or not the Agile PLM DB as DBCS
variable "provision_db" {
  type        = bool
  default     = false
  description = "To provision or not the Agile PLM DB as DBCS"
}

# The DBCS DB edition
variable "dbcs_db_edition" {
  type        = string
  default     = "ENTERPRISE_EDITION"
  description = "The DBCS DB edition"
}

# The shape for the dbcs instance.
variable "dbcs_instance_shape" {
  type        = string
  default     = "VM.Standard2.4"
  description = "The shape for the dbcs instance."
}

# The Agile PLM DBCS DB Admin PWD
variable "db_admin_password" {
  type        = string
  description = "The Agile PLM DBCS DB Admin PWD"
}

##################################
# Load Balancers config
##################################

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

# The load balancer listening port
variable "lb_port" {
  type        = number
  default     = 443
  description = "The load balancer listening port"
}

# The path to the load balancer CA certificate
variable "lb_ca_certificate" {
  type        = string
  default     = "./certs/ca.crt"
  description = "The path to the load balancer CA certificate"
}

# The path to the load balancer private_key
variable "lb_private_key" {
  type        = string
  default     = "./certs/my_cert.key"
  description = "The path to the load balancer private_key"
}

# The path to the load balancer public_certificate
variable "lb_public_certificate" {
  type        = string
  default     = "./certs/my_cert.crt"
  description = "The path to the load balancer public_certificate"
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


##################################
# Bastion host Config
##################################

# Whether or not a bastion and all of its resources (subnet/NSG/compute instance) should be created.
variable "create_bastion" {
  type        = bool
  description = "Whether or not a bastion and all of its resources (subnet/NSG/compute instance) should be created."
  default     = true
}

# The bastion image name
variable "bastion_image_name" {
  type        = string
  description = "The bastion image name"
  default     = "Oracle-Linux-7.7-2019.10.19-0"
}

##################################
# Application Servers Config
##################################

# The number of as instances
variable "as_num_inst" {
  type        = number
  default     = 2
  description = "The number of as instances"
}

# The shape for the as instances.
variable "as_instances_shape" {
  type        = string
  default     = "VM.Standard2.4"
  description = "The shape for the as instances."
}

# The size of the as instances boot volume.
variable "as_instances_boot_vol_size" {
  type        = number
  default     = 50
  description = "The size of the as instances boot volume."
}

# The aditional block volume size
variable "as_aditional_block_volume_size" {
  type        = number
  default     = 50
  description = "The aditional block volume size"
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

##################################
# File Manager Servers Config
##################################

# The number of fm instances
variable "fm_num_inst" {
  type        = number
  default     = 2
  description = "The number of fm instances"
}

# The shape for the fm instances.
variable "fm_instances_shape" {
  type        = string
  default     = "VM.Standard2.4"
  description = "The shape for the fm instances."
}

# The size of the fm instances boot volume.
variable "fm_instances_boot_vol_size" {
  type        = number
  default     = 50
  description = "The size of the fm instances boot volume."
}

# The aditional fm block volumes size
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

# Agile PLM file manager port
variable "file_mgr_port" {
  type        = number
  description = "Agile PLM file manager port"
  default     = "8080"
}

##################################
# Ansible Servers Config
##################################

# Whether or not an Ansible control machine and all of its resources (subnet/NSG/compute instance) should be created.
variable "create_ansible" {
  type        = bool
  description = "Whether or not an Ansible control machine and all of its resources (subnet/NSG/compute instance) should be created."
  default     = false
}

##################################
# DNS Servers Config
##################################

# Whether or not DNS forwarders and all of their resources (subnet/NSG/compute instance) should be created.
variable "create_dns" {
  type        = bool
  description = "Whether or not DNS forwarders and all of their resources (subnet/NSG/compute instance) should be created."
  default     = true
}
