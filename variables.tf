variable "hosts" {
  type = string

  description = <<EOF
Host(s) to target with Ansible

This can be a comma separated list or single host.
EOF
}

variable "variables" {
  type = map(any)

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
type    = list(string)
default = ["-b"]

description = <<EOF
Command line arguments passed to ansible
EOF
}

variable "environment" {
type = list(string)

default = [
"ANSIBLE_NOCOWS=true",
"ANSIBLE_RETRY_FILES_ENABLED=false",
"ANSIBLE_HOST_KEY_CHECKING=false",
]

description = <<EOF
Environment variables that will be set when running the playbook
EOF
}

#variable "on_destroy_failure" {
#type    = "string"
#default = "continue"

#description = <<EOF
#Should we fail if the deprovisioning failed? ["conftinue","fail"] ("continue")
#EOF
#}

variable "on_create_actions" {
  type    = list(string)
  default = ["setup"]

  description = <<EOF
A list of actions to run on creation of the object. Possible values are
usualy "create" and "setup".

The default action is to only run "setup" tasks. This
assumes that you are using a pre baked image that already had the creation
tasks applied.

If that is not the case you should set this parameter to `["create","setup"]`.
EOF
}

variable "on_destroy_actions" {
  type = list(string)
  default = ["destroy"]

  description = <<EOF
A list of actions to run on destruction of the object.

The default options is to run the destroy tasks.
EOF
}

