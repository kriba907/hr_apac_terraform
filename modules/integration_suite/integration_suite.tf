# ------------------------------------------------------------------------------------------------------
# Required provider
# ------------------------------------------------------------------------------------------------------
terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.7.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.3.0"
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Setup Integration Suite entitlement
# Usually entitlement does not exist for a subaccount
# service_name / app_name = integrationsuite
# plan_name     = standard_edition
# Id / plan_id = integrationsuite-standard_edition
# ------------------------------------------------------------------------------------------------------

/*
# Check if the entitlement already exists - if it does do not create a new one
data "btp_subaccount_entitlements" "subaccount_entitlements"{
  subaccount_id = var.subaccount_id
}

locals {
  existing_entitlements = [for entitlements in data.btp_subaccount_entitlements.subaccount_entitlements : entitlements]
  has_entitlement = contains(local.existing_entitlements.service_name,"integrationsuite")
}

output "entitlement" {
  value = local.existing_entitlements
  description = "entitlement"
}

output "has_entitlement" {
  value = local.has_entitlement
  description = "has_entitlement"
}
*/





resource "btp_subaccount_entitlement" "integrationsuite" {
  subaccount_id = var.subaccount_id
  service_name  = "integrationsuite"
  plan_name     = "standard_edition"
  amount        = 1
  #amount = local.has_entitlement ? 0 : 1
}

# Subscribe
resource "btp_subaccount_subscription" "integrationsuite" {
  subaccount_id = var.subaccount_id       #req
  app_name      = btp_subaccount_entitlement.integrationsuite.service_name
  plan_name     = btp_subaccount_entitlement.integrationsuite.plan_name
  depends_on    = [btp_subaccount_entitlement.integrationsuite]
  #parameters = jsonencode({
  #additional_features = ["build-integration-scenarios"] # Example if applicable
  #})
}

# ------------------------------------------------------------------------------------------------------
#  USERS AND ROLES
# ------------------------------------------------------------------------------------------------------
# Get all available subaccount roles
data "btp_subaccount_roles" "all" {
  subaccount_id = var.subaccount_id
  depends_on    = [btp_subaccount_subscription.integrationsuite, btp_subaccount_entitlement.integrationsuite]
}

# Create role collection "Integration Suite Administrator"
resource "btp_subaccount_role_collection" "Integration_Suite_Admin" {
  subaccount_id = var.subaccount_id
  name          = "Integration Suite Administrator"
  description   = "The role collection for an administrator on Integration Suite"

  roles = [
    for role in data.btp_subaccount_roles.all.values : {
      name                 = role.name
      role_template_app_id = role.app_id
      role_template_name   = role.role_template_name
    } if contains(["IntegrationProvisioningAdmin", "Administrator", "AuthGroup_Administrator", "AuthGroup_BusinessExpert", "AuthGroup_ContentPublisher", "AuthGroup_IntegrationDeveloper", "APIPortal.Administrator", "PI_Administrator", "PI_Integration_Developer"], role.role_template_name)
  ]
}

# Assign users to the role collection "Integration Suite Administrator"
resource "btp_subaccount_role_collection_assignment" "Integration_Suite_Admin" {
  for_each             = toset(var.integration_suite_admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "Integration Suite Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount_role_collection.Integration_Suite_Admin, btp_subaccount_subscription.integrationsuite, btp_subaccount_entitlement.integrationsuite]
}

/*
# Assign users to the role collection "PI_Administrator"
resource "btp_subaccount_role_collection_assignment" "PI_Administrator" {
  for_each             = toset(var.integration_suite_admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "PI_Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount_role_collection.Integration_Suite_Admin]
}
*/
