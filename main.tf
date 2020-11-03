###############################################################################

# Creates a list of all role sources
data "template_file" "versioning_helper" {
  count = length(var.variables.lifecycle_roles)
  template = lookup(var.variables.lifecycle_roles[count.index], "source")
}

###############################################################################

locals {
  # Prepare variables to pass them to the ansible playbook command
  variables   = jsonencode(var.variables)
  arguments   = join(" ", compact(var.arguments))
  environment = join(" ", var.environment)

  # SHA1 of all role sources
  role_version_sha1 = sha1(join(":", data.template_file.versioning_helper.*.rendered))
  # Use customized roles path to avoid conflicting version issues
  roles_path = "${abspath(path.root)}/.ansible/roles/${local.role_version_sha1}"

  create_vars = jsonencode({
    roles_path        = local.roles_path
    lifecycle_actions = var.on_create_actions
  })
  destroy_vars = jsonencode({
    roles_path        = local.roles_path
    lifecycle_order   = "reverse"
    lifecycle_actions = var.on_destroy_actions
  })

  # These commands run the ansible playbook included in this module with the
  # correct parameters and environment variables
  create_command  = "ANSIBLE_ROLES_PATH=${local.roles_path} ${local.environment} ansible-playbook ${path.module}/lifecycle.yml -e '${local.create_vars}' -e '${local.variables}' -i '${var.hosts},' ${local.arguments}"
  destroy_command = "ANSIBLE_ROLES_PATH=${local.roles_path} ${local.environment} ansible-playbook ${path.module}/lifecycle.yml -e '${local.destroy_vars}' -e '${local.variables}' -i '${var.hosts},' ${local.arguments}"
}

###############################################################################
# Ansible roles-playbook
# @TODO: reduce to single resource when #19679 is fixed

# on_destroy_failure == "continue"
resource "null_resource" "roles-playbook-continue" {
  count = var.on_destroy_failure == "continue" ? 1 : 0

  # @TODO: Remove when #23679 is fixed
  triggers = {
    destroy_command = local.destroy_command
  }
  lifecycle {
    ignore_changes = [triggers["destroy_command"]]
  }

  # Create
  provisioner "local-exec" {
    command = local.create_command
  }

  # Destroy
  provisioner "local-exec" {
    when       = destroy
    command    = self.triggers.destroy_command
    on_failure = continue
  }
}

# on_destroy_failure == "fail"
resource "null_resource" "roles-playbook-fail" {
  count = var.on_destroy_failure == "fail" ? 1 : 0

  # @TODO: Remove when #23679 is fixed
  triggers = {
    destroy_command = local.destroy_command
  }
  lifecycle {
    ignore_changes = [triggers["destroy_command"]]
  }

  # Create
  provisioner "local-exec" {
    command = local.create_command
  }

  # Destroy
  provisioner "local-exec" {
    when       = destroy
    command    = self.triggers.destroy_command
    on_failure = fail
  }
}

###############################################################################
