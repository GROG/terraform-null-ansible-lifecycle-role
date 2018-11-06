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
include other roles and provide them with the majority of there config/data
(stuff that usually goes into the `group_vars`).

Node/server specific settings can then be passed to this role from Terraform,
effectively replacing the `host_vars` data in a normal Ansible setup.

Besides this conceptual difference the role **must** include a `create.yml` and
`destroy.yml` file under the `tasks` dir.

- `create.yml` : Contains tasks that will be run when Terraform creates the
  resource. You could include the regular `main.yml` here if you want.

- `destroy.yml` : Contains tasks that will be run when Terraform destroys the
  resource. In a lot of setups this will just be an empty file.

An optional third `requirements.yml` file can be used to install role
requirements without adding them to the `meta/main.yml` file. (which would run
them automatically when destroying to) These can then be included in the
`create.yml` file with an `include_role` task.

In combination with a `meta/requirements.yml` file this could look like this;
```yaml
# tasks/requirements.yml

- name: Install role dependencies
  command: "ansible-galaxy install -r {{ role_path }}/meta/requirements.yml --force"
  delegate_to: localhost
  become: false
```

## Why use this module instead of a playbook?

This module allows you to define a node/server purely based on data. It also
decouples your Ansible config from your Terraform code which encourages re-use.

You could even get the configuration details from an external data source and
prevent any Ansible config inside the Terraform code.

## Usage

```hcl
# Some resource we will configure with ansible
resource "aws_instance" "node" {
    # ...
}

# Add ansible module
module "node-ansible-config" {
  source = "GROG/ansible-provisioning-role/null"
  version = "0.0.2"

  # Target, this can be a comma separated list
  target = "${aws_instance.node.public_ip}"

  ansible_variables = {
    # Special variable containing the roles that will be applied
    provisioning_roles = [
      {
        name   = "ansible-provisioning-setup"
        source = "git+ssh://git@github.com/grog/ansible-provisioning-setup"

        setup      = true
        setup_user = "root"
      },
      {
        name   = "ansible-provisioning-base-node"
        source = "git+ssh://git@github.com/grog/ansible-provisioning-base-node"
      }
    ]

    # These are some random vars to use during provisioning
    custom_setting = "1234"
    my_role_config = "test"
    # ...

  }
}
```

During creation Roles are applied in provided order. When destroying the
reverse order is used.

## Requirements

- Ansible (v2.5+)

## Inputs

| Variable | Description | Type | Default value |
|----------|-------------|------|---------------|
| `hosts` | Single host or comma separated list on which te roles will be applied | `string` | |
| `variables` | Ansible variables which will be passed with `-e` | `map` | |
| `arguments` | Ansible command arguments | `[]string` | `["-b"]` |
| `environment` | Environment variables that are set | `[]string` | `["ANSIBLE_NOCOWS=true", "ANSIBLE_RETRY_FILES=false"]` |
| `on_destroy_failure` | What to do on deprovisioning failure | `"continue"` or `"fail"`  | `continue` |

The `variables` map **must** contain a `provisioning_roles` list with the roles
that should be applied. Each entry in this list is a map, which can have
following keys;

| Key | Description | Required | Default |
|-----|-------------|----------|---------|
| `name` | The name of the role | `yes` | |
| `source` | The source of the role | `yes` | |
| `gather_facts` | Boolean to enable/disable fact gathering | `no` | `true` |
| `vars` | Dict assigned to the `{{ role_vars }}` variable | `no` | `{}` |
| `setup_user` | Alternative Ansible/remote user used for this role | `no` | `{{ remote_user }}` |
| `install_requirements` | Should `tasks/requirements.yml` be run | `no` | `true` |

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
