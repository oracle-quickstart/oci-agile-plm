# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
/*
# configure as instances
resource "null_resource" "expect_to_as_instances" {
  for_each = module.oci_instances_as.instance

  # upload environment variables file
  provisioner "file" {
    connection {
      bastion_host        = module.ent_base.bastion_instance.public_ip
      bastion_private_key = chomp(file(var.ssh_private_key_path))
      bastion_user        = "opc"
      user                = "opc"
      agent               = false
      private_key         = chomp(file(var.ssh_private_key_path))
      timeout             = "5m"
      host                = each.value.private_ip
    }

    source      = "../../scripts/agileplm-environment.sh"
    destination = "/tmp/agileplm-environment.sh"
  }

  # upload the Agile PLM instalation expect file
  provisioner "file" {
    connection {
      bastion_host        = module.ent_base.bastion_instance.public_ip
      bastion_private_key = chomp(file(var.ssh_private_key_path))
      bastion_user        = "opc"
      user                = "opc"
      agent               = false
      private_key         = chomp(file(var.ssh_private_key_path))
      timeout             = "5m"
      host                = each.value.private_ip
    }

    source      = "../../scripts/expect_install.exp"
    destination = "/home/opc/app/expect_install.exp"
  }

  # export environment variables and invoke the Agile PLM installation
  provisioner "remote-exec" {
    connection {
      bastion_host        = module.ent_base.bastion_instance.public_ip
      bastion_private_key = chomp(file(var.ssh_private_key_path))
      bastion_user        = "opc"
      user                = "opc"
      agent               = false
      private_key         = chomp(file(var.ssh_private_key_path))
      timeout             = "5m"
      host                = each.value.private_ip
    }

    inline = [
      "source /tmp/agileplm-environment.sh \"${each.value.private_ip}\" \"${module.lb_pub.lb[0].ip_addresses[0]}\" \"${var.domain_name}\" \"${each.value.display_name}\" \"${var.schema_name}\" \"${var.rcu_prefix}\" \"${var.demo_pass}\" \"${var.web_client_port}\" \"${var.file_mgr_port}\" \"${var.file_mgr_vault_path}\" \"${var.approve}\" \"${var.timeout}\" \"${var.as_admin_port}\" \"${var.as_prod_port}\"",
      "echo $(env | grep AGILE_PLM)"
    ]
  }
}

# configure fm instances
resource "null_resource" "expect_to_mf_instances" {
  for_each = module.oci_instances_fm.instance

  # upload environment variables file
  provisioner "file" {
    connection {
      bastion_host        = module.ent_base.bastion_instance.public_ip
      bastion_private_key = chomp(file(var.ssh_private_key_path))
      bastion_user        = "opc"
      user                = "opc"
      agent               = false
      private_key         = chomp(file(var.ssh_private_key_path))
      timeout             = "5m"
      host                = each.value.private_ip
    }

    source      = "../../scripts/agileplm-environment.sh"
    destination = "/tmp/agileplm-environment.sh"
  }

  # upload the Agile PLM instalation expect file
  provisioner "file" {
    connection {
      bastion_host        = module.ent_base.bastion_instance.public_ip
      bastion_private_key = chomp(file(var.ssh_private_key_path))
      bastion_user        = "opc"
      user                = "opc"
      agent               = false
      private_key         = chomp(file(var.ssh_private_key_path))
      timeout             = "5m"
      host                = each.value.private_ip
    }

    source      = "../../scripts/expect_install.exp"
    destination = "/home/opc/app/expect_install.exp"
  }

  # export environment variables and invoke the Agile PLM installation
  provisioner "remote-exec" {
    connection {
      bastion_host        = module.ent_base.bastion_instance.public_ip
      bastion_private_key = chomp(file(var.ssh_private_key_path))
      bastion_user        = "opc"
      user                = "opc"
      agent               = false
      private_key         = chomp(file(var.ssh_private_key_path))
      timeout             = "5m"
      host                = each.value.private_ip
    }

    inline = [
      "source /tmp/agileplm-environment.sh \"${each.value.private_ip}\" \"${module.lb_pub.lb[0].ip_addresses[0]}\" \"${var.domain_name}\" \"${each.value.display_name}\" \"${var.schema_name}\" \"${var.rcu_prefix}\" \"${var.demo_pass}\" \"${var.web_client_port}\" \"${var.file_mgr_port}\" \"${var.file_mgr_vault_path}\" \"${var.approve}\" \"${var.timeout}\" \"${var.as_admin_port}\" \"${var.as_prod_port}\" ",
      "echo $(env | grep AGILE_PLM)"
    ]
  }
}
*/