# Terraform AWS Hashistack

### This is a Work In Progress

This is a terraform module for setting up a Hashistack on AWS.

The HashiStack consists of Terraform, Consul, Vault, and Nomad.

After a short initial settup (providing keys and small config), and
a `terraform apply` the a user should be able to quickly deploy
containerized applications to a personal Nomad cluster.

### TODOs

- Ensure nodes find eachother properly
- Nice outputs on terraform apply for quick access
- Get Docker container running as example task
- Write out How to Use Docs
  - Variables necessary
  - Commands for ssh-ing
  - Commands for accessing
  - Commands for running nomad
  - Use TF output if possible
- Configuration Audit (every option on each service)

### Deps

Requires terraform 12.

### Inspirations

- https://github.com/nicholasjackson/terraform-aws-hashicorp-suite
- https://github.com/hashicorp/nomad/tree/master/terraform
