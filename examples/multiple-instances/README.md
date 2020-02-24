# OCI Agile PLM Module Example (Multiple Instances)

## Introduction

| Complexity |
|---|
| Complex |

This example shows how to utilize the Agile PLM module.  Here are many of the resources created in this example:

* 1x VCN
* 1x IGW
* 1x SVCGW
* 1x NATGW
* 1x DRG
* 3x Route Tables
* 2x DHCP Options
* Maybe up to 9x Subnets
* Maybe up to 6x NSGs
* 1x Security List (VCN-wide)
* 2x DNS forwarder instances
* 1x Bastion instance
* 1 X DBCS Database
* Application server compute instances
* File Manager server compute instances
* 2x LBs (1x public LB, 1x private LB)

This project creates a more complex topology with a configurable number of application server VMs and file manager VMs. For the DB layer the automation will provision a DBCS DB. After the provisioning is completed, on the application server and file manager VMS, the user will find the binaries needed to install and configure Agile PLM.

This example defines the routing policies and DNS profiles that will be used throughout a fictitious OCI environment.  Though this is just an example, it is common to find only a couple of unique policies, thus why this example showcases this.


## Topology Diagram
No topology diagram is provided for this.  Please refer to the Agile PLM module for diagrams of what the module deploys - this example is simply deploying this solution module.

## Using this example

### Generating SSL key

The keys should go in `./certs` folder. Here's an example of how this is done:

> Credit to: https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

#### Setup the CA:

```
openssl req -x509 -nodes -newkey rsa:4096 -keyout ./certs/ca.key -out ./certs/ca.crt -days 365
```

#### Setup a cert for the web service:

```
openssl genrsa -out ./certs/my_cert.key 2048
openssl req -new -sha256 -key ./certs/my_cert.key -subj "/C=US/ST=CA/O=SomePlace, Inc./CN=myorg.local" -out ./certs/my_cert.csr
openssl x509 -req -in ./certs/my_cert.csr -CA ./certs/ca.crt -CAkey ./certs/ca.key -CAcreateserial -out ./certs/my_cert.crt -days 500 -sha256
```

You should now have the following files in the `cert` subdirectory:

```
certs
├── ca.crt
├── ca.key
├── my_cert.crt
├── my_cert.csr
└── my_cert.key
```

These are referenced in the example code (so long as you use these filenames, you should be good to go).

### Terraform.tfvars
Prepare two variable files: 
-  `terraform.tfvars` with the required information (or feel free to copy the contents from `terraform.tfvars.template`).  The contents of `terraform.tfvars` should look something like the following:

```
tenancy_ocid = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
user_ocid = "ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
fingerprint= "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "~/.oci/oci_api_key.pem"
region = "us-phoenix-1" (or whatever region you prefer to use)
db_admin_password = "<your password goes here>"
```
- `agile-plm-multiple-instances.auto.tfvars` with the required information.  The contents of `agile-plm-multiple-instances.auto.tfvars` should look something like the following:

```
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
provision_db = true

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
provision_priv_lb = true

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
as_num_inst = 2

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
fm_num_inst = 2

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
```

See https://docs.cloud.oracle.com/iaas/images/ for a listing of OCI-provided image OCIDs (easily lookup the name, in case an image name is desired instead of an image OCID).

Then apply the example using the following commands:

```
$ terraform init
$ terraform plan
$ terraform apply
```
