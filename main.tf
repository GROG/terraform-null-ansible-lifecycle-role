locals {
  create_vars = {
    provisioning_actions = "${var.on_create_actions}"
  }
  destroy_vars = {
    provisioning_order = "reverse"
    provisioning_actions = "${var.on_destroy_actions}"
  }
}

# Ansible roles-playbook
resource "null_resource" "roles-playbook" {
  # Create
  provisioner "local-exec" {
    command = "${join(" ", var.environment)} ansible-playbook ${path.module}/provisioning.yml -e '${jsonencode(local.create_vars)}' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
  }

  # Destroy
  provisioner "local-exec" {
    when       = "destroy"
    command    = "${join(" ", var.environment)} ansible-playbook ${path.module}/provisioning.yml -e '${jsonencode(local.destroy_vars)}' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
    on_failure = "continue"
    # @TODO: Update when #19679 is fixed
    #on_failure = "${var.on_destroy_failure}"
  }
}
