# Copilot Instructions — Platform/DevOps Repository
 
This repository provisions and operates infrastructure using *Terraform*,
*Ansible, **Docker, and **Kubernetes/Helm*. These instructions apply to
every Copilot interaction (chat, inline completion, and PR review) in this
repo. File-type-specific detail lives in .github/instructions/*.instructions.md
and takes precedence for its matched files, but the principles below always
apply.
 
## General Review Priorities (in order)
 
1. *Security* — secrets exposure, privilege escalation, network exposure,
   supply-chain risk.
2. *Blast radius* — could this change take down a shared environment,
   delete state/data, or affect resources outside the PR's stated scope?
3. *Reliability* — idempotency, retries/timeouts, rollback safety.
4. *Cost* — oversized instances/nodes, orphaned resources, no autoscaling
   bounds.
5. *Maintainability* — naming, module structure, duplication, drift risk.
 
## Cross-Cutting Rules (all IaC/config file types)
 
- No hardcoded secrets, API keys, tokens, passwords, or connection strings
  anywhere — including in comments, default values, or "example" configs.
  Flag them even in files that look like fixtures.
- No use of latest, master, or otherwise unpinned versions for base
  images, provider versions, module sources, Helm chart versions, or
  Ansible collection/role versions. Everything should be pinned to a
  specific version or digest.
- Every resource/module/task that talks to a network dependency
  (API call, DB connection, package registry) should have an explicit
  timeout and a bounded retry strategy — no infinite retries.
- Flag anything that looks like it grants broader permissions, wider
  network ingress, or more privilege than the PR description justifies
  ("least privilege" check).
- Flag destructive operations (terraform destroy-adjacent resources,
  force_delete, --force, volume/PVC deletion, kubectl delete,
  Ansible tasks with state: absent) and confirm they're intentional and
  gated appropriately (e.g., behind a variable, a confirmation, or a
  separate manual step).
- Comment out is not version control — flag commented-out blocks of
  config/code left in place; they should be deleted (git history has them).
- Prefer data-driven / parameterized definitions (variables, values files,
  Helm values, Ansible vars) over copy-pasted, hardcoded blocks repeated
  across environments.
 
## PR Review Tone & Output
 
- Group findings by severity: *Blocking* (security/data-loss risk),
  *Should Fix* (reliability/cost/maintainability), *Nit* (style).
  Comments should say what to change, not just what's wrong.
- If a finding depends on runtime context Copilot can't see (e.g., is this
  cluster actually public-facing?), phrase it as a question rather than a
  flat assertion.
- Don't repeat the same class of finding on every line — summarize a
  recurring issue once and reference the additional location