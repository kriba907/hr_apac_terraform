variable "subaccount_id" {
  type        = string
  description = "The subaccount ID."
}

variable "subaccount_name" {
  type        = string
  description = "The subaccount name"
}

variable "integration_suite_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for Integration Suite."
}

variable "subaccount_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for the subaccount."
}

variable "cf_space_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for the subaccount."
}

variable "org_name" {
  type        = string
  description = "CF Org Name"
}
