variable "subaccount_id" {
  type        = string
  description = "The subaccount ID."
  default     = "hr-apac-dev"
}

variable "org_name" {
  type        = string
  description = "CF Org Name"
}

variable "org_Id" {
  type        = string
  description = "CF Org ID"
}

variable "subaccount_name" {
  type        = string
  description = "The subaccount name"
}

variable "api_man_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for the subaccount."
}