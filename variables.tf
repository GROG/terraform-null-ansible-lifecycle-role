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

variable "on_create_tasks" {
  type = "list"
  default = ["setup"]

  description = <<EOF
A list of tasks to run on creation of the object. Possible values are
usualy "create" and "setup".

The default action is to only run "setup" tasks. This
assumes that you are using a pre baked image that already had the creation
tasks applied.

If that is not the case you should set this parameter to `["create","setup"]`.

Under the hood `role/tasks/<on_create_tasks[...]>/main.yml` will be included on
creation. It is possible to add your own custom tasks options. Just make sure
that role/tasks/<custom_tasks>/main.yml exists.
EOF
}

variable "on_destroy_tasks" {
  type = "list"
  default = ["destroy"]

  description = <<EOF
A list of tasks to run on destruction of the object. Currently the only
option is "destroy" (or an empty list).

The default options is to run the destroy tasks.

Under the hood `role/tasks/<on_destroy_tasks[...]>/main.yml` will be included on
destruction. It is possible to add your own custom tasks options. Just make sure
that role/tasks/<custom_tasks>/main.yml exists.
EOF
}
