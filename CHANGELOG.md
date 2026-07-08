# Changelog

All notable changes to this project are documented here. Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-07-07

### Added
- Docker Swarm bootstrap via SSM Parameter Store: the manager runs `docker swarm init` and publishes its join token, workers poll for it and join automatically. Previously `user_data.sh` installed Docker on every node but never formed a cluster.
- Least-privilege IAM roles for the manager (write) and workers (read-only) scoped to a single SSM parameter path, plus scoped KMS permissions.
- Reproducible AMI lookup via `aws_ssm_parameter` instead of a `most_recent` filter.
- `worker_count` variable (previously hardcoded to 2).
- Security group hardening: required `ssh_allowed_cidr_blocks` variable with no public default, a `lifecycle.precondition` blocking `0.0.0.0/0` unless explicitly opted into, and `enable_web_ingress` gating ports 80/443.
- IMDSv2 enforcement and EBS encryption at rest on every EC2 instance.
- VPC Flow Logs to CloudWatch, and the VPC's default security group locked down to zero rules.
- `default_tags` on the AWS provider.
- GitHub Actions CI: `terraform fmt`, `terraform validate`, `tflint`, `checkov`, and `gitleaks`, plus matching local pre-commit hooks.
- Optional S3 + DynamoDB remote backend via a one-time `bootstrap/` stack, with per-environment backend and `.tfvars.example` files for dev/staging/prod.
- Module-level README files generated with `terraform-docs`.
- This README, a CHANGELOG, and an MIT license.

### Changed
- Default instance type from `t2.micro` to `t3.micro` (Nitro-based: EBS-optimized by default, native IMDSv2 support).
- AWS provider constraint from `~> 4.0` to `~> 5.0`; `required_version` bumped to `>= 1.5.0`.

### Fixed
- The core bug that gave this repo its name: a Docker Swarm cluster is now actually formed on `apply`.
