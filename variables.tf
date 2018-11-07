variable "hosts" {
  type = "string"

  description = <<EOF
Host(s) to target with Ansible

This can be a comma separated list or single host.
EOF
}

variable "variables" {
  type = "map"

  description = <<EOF
Ansible variables passed to the provisioning playbook.

Must contain 'provisioning_roles' variable!
  provisioning_roles: [
    {
      name: "example"
      source: "git+ssh://git@gitlab.com/myorg/ansible-role-example,v1.2.3"

      # Optional
      setup: true
      setup_user: install
      install_requirements: false
    }
  ]
EOF
}

variable "arguments" {
  type    = "list"
  default = ["-b"]

  description = <<EOF
Command line arguments passed to ansible
EOF
}

variable "environment" {
  type = "list"

  default = [
    "ANSIBLE_NOCOWS=true",
    "ANSIBLE_RETRY_FILES_ENABLED=false",
  ]

  description = <<EOF
Environment variables that will be set when running the playbook
EOF
}

variable "on_destroy_failure" {
  type    = "string"
  default = "continue"

  description = <<EOF
Should we fail if the deprovisioning failed? ["conftinue","fail"] ("continue")
EOF
}
