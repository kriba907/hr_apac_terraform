variable "globalaccount" {
  type = string
}

variable "username" {
  type = string
  sensitive=true
}

variable "password" {
  type = string
  sensitive=true
}

variable "subaccount_domain_prefix" {
  type        = string
  description = "The prefix used for the subaccount domain"
  default     = ""
}

# BusinessProcess_MF_Dev
variable "subaccount_name_dev" {
  type        = string
  description = "The subaccount name."
  default     = "hr-apac-dev"
}

# BusinessProcess_MF_Dev
variable "subaccount_name_test" {
  type        = string
  description = "The subaccount name."
  default     = "hr-apac-qa"
}

# BusinessProcess_MF_Dev
variable "subaccount_name_prod" {
  type        = string
  description = "The subaccount name."
  default     = "hr-apac-prod"
}

variable "region" {
  type        = string
  description = "The region where the subaccount shall be created in."
  default     = ""
}

#------------------------------------------------------------------------------------#
# Variables needed to set up Entitlements, service subscription and Role Collections
#------------------------------------------------------------------------------------#
variable "build_code_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for SAP Build Code."
}

variable "build_code_developers" {
  type        = list(string)
  description = "Defines the colleagues who are developers for SAP Build Code."
}

variable "application_studio_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for SAP Business Application Studio"
}

variable "application_studio_developers" {
  type        = list(string)
  description = "Defines the colleagues who are developers for SAP Business Application Studio"
}

variable "application_studio_extension_deployer" {
  type        = list(string)
  description = "Defines the colleagues who are extension deployers for SAP Business Application Studio"
}
#------------------------------------------------------------------------------------#

variable "process_automation_admins" {
  type        = list(string)
  description = "Defines the users who have the role of ProcessAutomationAdmin in SAP Build Process Automation"
}

variable "process_automation_developers" {
  type        = list(string)
  description = "Defines the users who have the role of ProcessAutomationDeveloper in SAP Build Process Automation"
}

variable "process_automation_participants" {
  type        = list(string)
  description = "Defines the users who have the role of ProcessAutomationParticipant in SAP Build Process Automation"
}

#------------------------------------------------------------------------------------#

variable "integration_suite_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for Integration Suite."
}

variable "subaccount_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for Integration Suite."
}

variable "cf_space_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for Integration Suite."
}

variable "api_man_admins" {
  type        = list(string)
  description = "Defines the colleagues who are admins for Integration Suite."
}
