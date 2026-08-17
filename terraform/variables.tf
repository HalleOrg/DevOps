variable "environment" {
  description = "Deployment environment/workspace name (e.g., dev, staging, prod)."
  type        = string
}

variable "config" {
  description = "Additional configuration overrides for this stack."
  type        = map(any)
  default     = {}
}