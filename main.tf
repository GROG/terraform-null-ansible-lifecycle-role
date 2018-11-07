# Ansible roles-playbook
resource "null_resource" "roles-playbook" {
  # Triggers updating this resource (re-running the playbook)
  triggers = {
    hosts       = "${var.hosts}"
    variables   = "${jsonencode(var.variables)}"
    arguments   = "${join(" ", var.arguments)}"
    environment = "${join(" ",var.environment)}"
  }

  # Create provisioner
  provisioner "local-exec" {
    command = "${join(" ", var.environment)} ansible-playbook ${path.module}/provisioner.yml -e 'provisioner=create' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
  }

  # Destroy provisioner
  provisioner "local-exec" {
    when       = "destroy"
    command    = "${join(" ", var.environment)} ansible-playbook ${path.module}/provisioner.yml -e 'provisioner=destroy' -e '${jsonencode(var.variables)}' -i '${var.hosts},' ${join(" ", compact(var.arguments))}"
    on_failure = "continue"
  }
}
