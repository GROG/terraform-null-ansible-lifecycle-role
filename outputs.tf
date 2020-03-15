###############################################################################

output "id" {
  value = var.on_destroy_failure == "continue" ? null_resource.roles-playbook-continue.0.id : null_resource.roles-playbook-fail.0.id

  description = <<EOF
Resource ID

This can be used to trigger updates for other resources.
EOF

}

###############################################################################
