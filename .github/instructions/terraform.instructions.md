---
applyTo: '**/*.tf,**/*.tfvars'
---
# Terraform Review Standards
 
## Security
- No hardcoded credentials, access keys, or connection strings in .tf or
  .tfvars files — these belong in a secret manager (Vault, AWS Secrets
  Manager, SOPS) or injected via CI secret variables, never committed,
  even in terraform.tfvars.example style files.
- Provider and module versions must be pinned (required_providers with
  an exact or ~> constraint; module source with a version or commit
  SHA, not a floating branch/tag like main).
- State should never be local for anything beyond a personal sandbox —
  flag missing backend configuration or local state in shared modules.
- IAM/role/policy resources should follow least privilege — flag
  * actions/resources, overly broad AssumeRolePolicyDocument
  principals, or security groups with 0.0.0.0/0 ingress on
  non-HTTP(S) ports.
- Flag any resource with prevent_destroy = false (or missing) on
  stateful resources (databases, storage buckets, PVs) in production-like
  environments/workspaces.
 
## Reliability & Blast Radius
- Check for lifecycle { create_before_destroy = true } on resources
  where replacement would cause downtime (load balancers, launch
  templates, DNS records).
- Flag count/for_each usage that could unintentionally destroy and
  recreate many resources on a simple reorder (e.g., using a list index
  instead of a stable key).
- Confirm destructive-by-default settings (force_delete,
  skip_final_snapshot = true, deletion_protection = false) are not
  set on anything that looks like production.
- Remote state data sources (terraform_remote_state) should not create
  tight coupling that breaks plan/apply for unrelated stacks.
 
## Maintainability
- Variables should have type and description; avoid any-typed
  variables where a concrete type/object is feasible.
- Repeated resource blocks across environments should be modules with
  environment-specific .tfvars, not copy-pasted .tf files.
- Outputs that expose sensitive values should be marked sensitive = true.
 
## Cost
- Flag hardcoded large instance types/node counts without a variable or
  comment justifying the size.
- Flag missing autoscaling bounds (no max_size, unbounded node pools).