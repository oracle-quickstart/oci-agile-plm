# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# For more detailed description, see: https://docs.oracle.com/en/solutions/deploy-agileplm-on-cloud/download-terraform-modules-and-set-variables.html#GUID-1D4D7170-6697-433E-8F2C-A2B282BEF3D9

##################################
# Common Configurations
##################################

# Default OCID of the compartment 
default_compartment_id = "<default compartment id>"

# Compute instances ssh public keys
default_ssh_auth_keys = ["<ssh_public_key_1>", "<ssh_public_key_2>", "..."]

# Compute instances ssh private key
ssh_private_key_path = "<ssh_private_key>"

# The OCID of the Agile PLM custom image. Use this ID across all provisioned Agile PLM instances including application servers and file managers. Do not use this ID for DBCS, Bastion, DNS and Ansible. For a listing of the custom images, see https://docs.cloud.oracle.com/en-us/iaas/images/
default_img_id = null

# The name of the Agile PLM custom image. Use this name across all provisioned Agile PLM instances including application servers and file managers. Do not use this name for DBCS, Bastion, DNS and Ansible.
default_img_name = null

# The name of the Agile PLM image in the Oracle Marketplace. Use this name across all provisioned Agile PLM instances including application servers and file managers. Do not use this name for DBCS, Bastion, DNS and Ansible. You must provide both the image name and the version for the Terraform plan to execute.
default_mkp_image_name = "Agile PLM Image"

# The version of the Agile PLM image in the Oracle Marketplace. Use this name across all provisioned Agile PLM instances including application servers and file managers. You must provide both the image name and the version for the Terraform plan to execute.
default_mkp_image_version = "1.5"

##################################
# Database Configurations
##################################

# Whether or not to provision the Agile PLM database as DB System
provision_db = false

# The name of the DB System DB edition
dbcs_db_edition = "ENTERPRISE_EDITION"

# The shape for the DB System instance.
dbcs_instance_shape = "VM.Standard2.4"

# The Agile PLM DB System DB Admin password
db_admin_password = "WelcomeOrclAdmin1-2#"

##################################
# Load Balancers Configurations
##################################

# Whether or not to provision the public load balancer for the Agile PLM
provision_pub_lb = true

# Whether or not to provision the private load balancer for the Agile PLM
provision_priv_lb = false

# The load balancer listening port
lb_port = 443

# The path to the load balancer route key CA certificate(CA)
lb_ca_certificate = "./certs/ca.crt"

# The path to the load balancer private_key
lb_private_key = "./certs/my_cert.key"

# The path to the load balancer public_certificate
lb_public_certificate = "./certs/my_cert.crt"

# LB - generic - Rule Set-specific variables 
# In here we need to specify the required headers for load balancers that are in front of WLS(Weblogic Server)
rule_sets = {
  agile_plm_lb_headers = [
    {
      action = "ADD_HTTP_REQUEST_HEADER"
      header = "WL-Proxy-SSL"
      prefix = null
      suffix = null
      value  = "true"
    },
    {
      action = "ADD_HTTP_REQUEST_HEADER"
      header = "is_ssl"
      prefix = null
      suffix = null
      value  = "ssl"
    }
  ]
}

##################################
# Bastion host Configurations
##################################

# Whether or not to create bastion and all of its resources(subnet/NSG/compute instance).
create_bastion = true

# The name of the bastion image
bastion_image_name = "Oracle-Linux-7.7-2020.01.28-0"

####################################
# Application Servers Configurations
####################################

# The number of application server instances
as_num_inst = 1

# The shape for the application server instances.
as_instances_shape = "VM.Standard2.4"

# The size of the application server instances boot volume.
as_instances_boot_vol_size = 55

# The additional block volumes size
as_aditional_block_volume_size = 60

# The additional application server block volume mount point
as_aditional_block_volume_mount_point = "/u01"

# The additional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze
as_volumes_backup_policy = "Bronze"

# The production port that the application servers managed servers on a compute node are listening on. The listening port for the AS WLS Managed Servers.
as_prod_port = 8001

# The admin port application servers admin server is listening on. The listening port for the AS WLS Admin Server.
as_admin_port = 9001

#####################################
# File Manager Servers Configurations
#####################################

# The number of file manager instances
fm_num_inst = 0

# The shape for the file manager instances.
fm_instances_shape = "VM.Standard2.4"

# The size of the file manager instances boot volume.
fm_instances_boot_vol_size = 55

# The additional block volumes size
fm_aditional_block_volume_size = 60

# The additional file manager block volume mount point
fm_aditional_block_volume_mount_point = "/u01"

# The additional block volumes backup policy: Bronze, Silver or Gold. Default = Bronze. Null = Bronze
fm_volumes_backup_policy = "Bronze"

# The production port that the file manager servers are listening on
file_mgr_port = 8080


##################################
# Ansible Servers Configuration
##################################

# Whether or not to create an Ansible control machine and all of its resources (subnet/NSG/compute instance).
create_ansible = false

##################################
# DNS Servers Configuration
##################################

# Whether or not to create DNS forwarders and all of their resources (subnet/NSG/compute instance) 
create_dns = true
