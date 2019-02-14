# Ansible roles-playbook
resource "null_resource" "roles-playbook" {
  # Triggers updating this resource (re-running the playbook)
  triggers = {
    hosts       = "${var.hosts}"
    variables   = "${jsonencode(var.variables)}"
    arguments   = "${join(" ", var.arguments)}"
    environment = "${join(" ",var.environment)}"
  }

  # Create
  provisioner "local-exec" {
    command = "${join(" ", var.environment)} ansible-playbook ${path.module}/provisioning.yml -e 'provisioning_actions=${join(",", var.on_create_actions)}' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
  }

  # Destroy
  provisioner "local-exec" {
    when       = "destroy"
    command    = "${join(" ", var.environment)} ansible-playbook ${path.module}/provisioning.yml -e 'provisioning_order=reverse provisioning_actions=${join(",", var.on_destroy_actions)}' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
    on_failure = "${var.on_destroy_failure}"
  }
}
