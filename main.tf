###############################################################################

locals {
  create_vars = {
    lifecycle_actions = var.on_create_actions
  }
  destroy_vars = {
    lifecycle_order   = "reverse"
    lifecycle_actions = var.on_destroy_actions
  }

  # We use a custom roles path to avoid version conflicts while allowing role caching
  #  (still room for improvement, as their might be conflicts between lifecycle roles)
  environment = merge(var.environment,["ANSIBLE_ROLES_PATH=${path.module}/.ansible/roles"])
}

###############################################################################
# Ansible roles-playbook

resource "null_resource" "roles-playbook-continue" {
  # @TODO: Update when #19679 is fixed
  count = "1 if on_destroy_failure == continue"

  # Create
  provisioner "local-exec" {
    command = "${join(" ", var.environment)} ansible-playbook ${path.module}/lifecycle.yml -e '${jsonencode(local.create_vars)}' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
  }

  # Destroy
  provisioner "local-exec" {
    when       = destroy
    command    = "${join(" ", var.environment)} ansible-playbook ${path.module}/lifecycle.yml -e '${jsonencode(local.destroy_vars)}' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
    # @TODO: Update when #19679 is fixed
    on_failure = continue
  }
}

resource "null_resource" "roles-playbook-fail" {
  # @TODO: Update when #19679 is fixed
  count = "1 if on_destroy_failure == fail"

  # Create
  provisioner "local-exec" {
    command = "${join(" ", var.environment)} ansible-playbook ${path.module}/lifecycle.yml -e '${jsonencode(local.create_vars)}' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
  }

  # Destroy
  provisioner "local-exec" {
    when       = destroy
    command    = "${join(" ", var.environment)} ansible-playbook ${path.module}/lifecycle.yml -e '${jsonencode(local.destroy_vars)}' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
    # @TODO: Update when #19679 is fixed
    on_failure = fail
  }
}

###############################################################################
