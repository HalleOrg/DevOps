This file gives shared context to any AI coding/review agent used in this repo (GitHub Copilot, Claude Code, Cursor, etc.), so review and code-gen behavior stays consistent regardless of tool.
Stack
	•	Terraform — cloud infrastructure provisioning.
	•	Ansible — configuration management / VM bootstrapping.
	•	Docker — application containerization.
	•	Kubernetes + Helm — container orchestration and deployment.
Ground Rules for Any Agent
	•	Treat .github/copilot-instructions.md and .github/instructions/*.instructions.md as the source of truth for review standards — don't restate different rules here.
	•	Never suggest or auto-fix by hardcoding a secret "just to make it work." Point to the secrets-management pattern already in use in this repo instead (see docker/README and ansible/README for how each layer handles secrets).
	•	Prefer minimal, reviewable diffs over large refactors when fixing a flagged issue, unless asked for a refactor explicitly.
	•	When unsure whether something is prod-facing, ask rather than assume.