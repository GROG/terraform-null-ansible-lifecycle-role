# terraform-null-ansible-provisioning-role

[![Latest tag][tag_image]][tag_url]
[![Gitter chat][gitter_image]][gitter_url]

A Terraform module for applying Ansible "provisioning" roles.

## What are Ansible provisioning roles?

An Ansible provisioning role is a very opinionated high level role containing
lots of configuration details. (Please contact me with better naming
suggestions)

Unlike a regular role, which tries to be as general as possible, a provisioning
role contains information about your specific setup. It should ideally only
include other roles and provide them with the majority of their config/data
(stuff that usually goes into the `group_vars`).

Node/server specific settings can then be passed to this role from Terraform,
effectively replacing the `host_vars` data in a normal Ansible setup.

Provisioning roles are also ideal to use in combination with packer. Tasks for
creating an image are separated from the instance specific setup tasks which
makes it easy to reuse the code.

To keep all life cycle management code in one place a provisioning role has
several sub directories under its tasks dir. Usually these will be `create`,
`setup`, `update` and `destroy`. Each containing a `main.yml` and possibly
other tasks files.

In an ideal situation Packer will run the create tasks to build an image.
Terraform then deploys that image and runs the setup tasks. During the lifetime
of the resource updates can be performed by regular Ansible runs running the
update tasks. At the end of the resources lifetime Terraform runs the destroy
tasks when it destroys the resource.

An optional `requirements.yml` file can be used to install role requirements
without adding them to the `meta/main.yml` file. (which would also run the
tasks in the roles on destruction) These roles can then be included in the
`create/main.yml` file with an `include_role` task.

In combination with a `meta/requirements.yml` file this could look like this;
```yaml
# meta/requirements.yml
- src: user.apache
  version: v1.0.0

# tasks/requirements.yml

- name: Install role dependencies
  command: "ansible-galaxy install -r {{ role_path }}/meta/requirements.yml --force"
  delegate_to: localhost
  become: false

# tasks/create/main.yml
- name: Install apache
  include_role:
    name: "user.apache"
```

Provisioning roles are a fairly new concept and major changes to their
specifications might still happen.

## Why use this module instead of a playbook?

This module allows you to define a node/server purely based on data. It also
decouples your Ansible config from your Terraform code which encourages re-use.

You could even get the configuration details from an external data source and
prevent any Ansible config inside the Terraform code.

Using provisioning roles makes it easy to share Ansible code between Packer and
Terraform.

## Usage

```hcl
# A resource we will configure with ansible
resource "aws_instance" "node" {
    # ...
}

# Add ansible module
module "node-ansible-config" {
  source = "GROG/ansible-provisioning-role/null"

  # Target, this can be a comma separated list
  hosts = "${aws_instance.node.public_ip}"

  ansible_variables = {
    # Special variable containing the roles that will be applied
    provisioning_roles = [
      {
        name   = "ansible-provisioning-base_node"
        source = "git+ssh://git@github.com/grog/ansible-provisioning-base_node"

        vars = {
            some_var = true
            # ...
        }
      },
      {
        name   = "ansible-provisioning-nomad_cluster_node"
        source = "git+ssh://git@github.com/grog/ansible-provisioning-nomad_cluster_node"
      }
    ]

    # These are some random vars to use during provisioning (set with -e)
    custom_setting = "1234"
    my_role_config = "test"
    # ...

    # These are set with set_facts
    global_vars = {
        remote_user = "install"
        # ...
    }
  }
}
```

During creation Roles are applied in provided order. When destroying the
reverse order is used.

Updating parameters or variables will not trigger a new playbook run. Terraform
is not the best way to perform updates during the lifetime of a resource.
That's why this role will not encourage that behavior. If you do want to
re-trigger the `on_create_actions` without running the `on_destroy_actions` you
can taint the resource. This behavior is the result of the on destroy
provisioners not being triggered when a resource is tainted.

A future release might add toggleable triggers if there is any interest for this.

## Requirements

- Ansible (v2.5+)

## Inputs

| Variable | Description | Type | Default value |
|----------|-------------|------|---------------|
| `hosts` | Single host or comma separated list on which the roles will be applied | `string` | |
| `variables` | Ansible variables which will be passed with `-e` | `map` | |
| `arguments` | Ansible command arguments | `[]string` | `["-b"]` |
| `environment` | Environment variables that are set | `[]string` | `["ANSIBLE_NOCOWS=true", "ANSIBLE_RETRY_FILES=false"]` |
| `on_create_actions` | What actions to run when creating the resource | `[]string`  | `["setup"]` |
| `on_destroy_actions` | What actions to run when destroying the resource | `[]string`  | `["destroy"]` |
<!--| `on_destroy_failure` | What to do on deprovisioning failure | `"continue"` or `"fail"`  | `continue` |-->

The `variables` map **must** contain a `provisioning_roles` list with the roles
that should be applied. Each entry in this list is a map, which can have
following keys;

| Key | Description | Required | Default |
|-----|-------------|----------|---------|
| `name` | The name of the role | `yes` | |
| `source` | The source of the role | `yes` | |
| `gather_facts` | Boolean to enable/disable fact gathering | `no` | `true` |
| `enabled_actions` | Enabled provisioning actions | `no` | undefined (all actions)  |
| `disabled_actions` | Disabled provisioning actions | `no` | `[]` |
| `install_requirements` | Should `tasks/requirements.yml` be run | `no` | `true` |
| `vars` | Dict assigned to the `{{ role_vars }}` variable | `no` | `{}` |

The `variables` map can also include a `global_vars` dict for which each
key/value pair will be set with the `set_fact` module. This could be handy as
the top level vars will be set with `-e` which makes it impossible to overrule
them for specific cases.

## Outputs

| Variable | Description | Type |
|----------|-------------|------|
| `id` | Resource ID | `string` |

## Contributing
All assistance, changes or ideas [welcome][issues]!

## Author
By [G. Roggemans][groggemans]

## License
MIT

[tag_image]:            https://img.shields.io/github/tag/GROG/terraform-null-ansible-provisioning-role.svg
[tag_url]:              https://github.com/GROG/terraform-null-ansible-provisioning-role
[gitter_image]:         https://badges.gitter.im/GROG/chat.svg
[gitter_url]:           https://gitter.im/GROG/chat

[issues]:               https://github.com/GROG/terraform-null-ansible-provisioning-role
[groggemans]:           https://github.com/groggemans
