variable "environment" {
  description = "Deployment environment/workspace name (e.g., dev, staging, prod)."
  type        = string
}

variable "config" {
 type    = any
 default = {}
}