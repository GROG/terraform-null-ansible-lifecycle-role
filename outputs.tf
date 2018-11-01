output "id" {
  value = "${null_resource.roles-playbook.id}"

  description = <<EOF
Resource ID

This can be used to trigger updates from other resources.
EOF
}
