# Terraform AWS Hashistack

### This is a Work In Progress

This is a terraform module for setting up a Hashistack on AWS.

The HashiStack consists of Terraform, Consul, and Nomad.

After a short initial settup (providing keys and small config), and
a `terraform apply` the a user should be able to quickly deploy
containerized applications to a personal Nomad cluster.

### Deps

This was written with terraform 12.
