# Terraform AWS Hashistack

### This is a Work In Progress

This is a terraform module for setting up a Hashistack on AWS.

The HashiStack consists of Terraform, Consul, Vault, and Nomad.

After a short initial settup (providing keys and small config), and
a `terraform apply` the a user should be able to quickly deploy
containerized applications to a personal Nomad cluster.

### TODOs

- Get Fabio and Docker container running as example tasks
- Add separate server and client nodes
  - With option for cheap dev version?
- Get Consul template running
- Nice outputs on terraform apply for quick
  access
- Write out How to Use Docs
  - Variables necessary
  - Commands for ssh-ing
  - Commands for accessing
  - Commands for running nomad
  - Use TF output if possible
- Split up startup script into various templates
- Add Vault
- Configuration Audit (every option on each service)

### Deps

This was written with terraform 12.

### Inspirations

https://github.com/nicholasjackson/terraform-aws-hashicorp-suite
