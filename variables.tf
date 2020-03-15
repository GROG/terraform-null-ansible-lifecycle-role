###############################################################################

variable "hosts" {
  type = string

  description = <<EOF
Host(s) to target with Ansible

This can be a comma separated list or single host.
EOF
}

variable "variables" {
  type = any

  description = <<EOF
Ansible variables passed to the lifecycle playbook.

Must contain 'lifecycle_roles' variable!
  lifecycle_roles: [
    {
      name: "example"
      source: "git+ssh://git@gitlab.com/myorg/ansible-role-example,v1.2.3"
      vars:
        my_var: value
    }
  ]
EOF
}

###############################################################################
# Optional parameters

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
Environment variables that will be set when running the playbook.

By default we set the Ansible roles path to be relative to the terraform module
folder. By doing this the versions needed for this module won't interfere with
other versions.
EOF
}

variable "on_destroy_failure" {
  type    = string
  default = "continue"

  description = <<EOF
Should we fail if the destroy action failed? ["conftinue","fail"] ("continue")
EOF
}

variable "on_create_actions" {
  type    = list(string)
  default = ["deploy"]

  description = <<EOF
A list of actions to run on creation of the object. Possible values are
usualy "build" and "deploy".

The default action is to only run "deploy" tasks. This
assumes that you are using a pre baked image that already had the build
tasks applied.

If that is not the case you should set this parameter to ["build","deploy"].
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

###############################################################################
