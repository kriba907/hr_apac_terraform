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


/*
# Assign users to the role collection "Subaccount Administrator"
resource "btp_subaccount_role_collection_assignment" "API_Man_Administrator" {
  for_each             = toset(var.api_man_admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "APIPortal.Administrator"
  user_name            = each.value
  //depends_on           = [btp_subaccount_role_collection.Integration_Suite_Admin]
}
*/

//Get the Cloud Foundry Org ID details - pass the Org name
data "cloudfoundry_org" "org" {
  name = var.org_name
}

//get the Organization Space details by passing Org ID and Space name
data "cloudfoundry_space" "space"{
  name      = "dev-space"
  org       = data.cloudfoundry_org.org.id
  //depends_on = [ cloudfoundry_space.space ]
}



data "btp_subaccount_roles" "all" {
  subaccount_id = var.subaccount_id
  //depends_on    = [btp_subaccount_subscription.integrationsuite, btp_subaccount_entitlement.integrationsuite]
}

# Create role collection "API Management Administrator"
resource "btp_subaccount_role_collection" "api_man_admin_rc" {
  subaccount_id = var.subaccount_id
  name          = "API Management Administrator"
  description   = "The role collection for an administrator on API Management"

  roles = [
    for role in data.btp_subaccount_roles.all.values : {
      name                 = role.name
      role_template_app_id = role.app_id
      role_template_name   = role.role_template_name
    } if contains(["APIPortalAdmin", "CatalogIntegration", "MultitenancyCallbackRoleTemplate", "onboardingtemplate", "AccessAllAccessPoliciesArtifacts", "AccessPoliciesEdit", "APIPortal.Administrator", "AccessPoliciesRead",], role.role_template_name)
  ]
}

# Assign users to the role collection "API Management Administrator"
resource "btp_subaccount_role_collection_assignment" "api_man_admin_rc_ass" {
  for_each             = toset(var.api_man_admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "API Management Administrator"
  user_name            = each.value
  depends_on           = [btp_subaccount_role_collection.api_man_admin_rc ]
}

/*
# Assign users to the role collection "Integration Suite Administrator"
resource "btp_subaccount_role_collection_assignment" "api_man_rolecollection_ass1" {
  for_each             = toset(var.api_man_admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "APIManagement.SelfService.Administrator"
  user_name            = each.value
  //depends_on           = [btp_subaccount_role_collection.Integration_Suite_Admin, btp_subaccount_subscription.integrationsuite, btp_subaccount_entitlement.integrationsuite]
}
# Assign users to the role collection "Integration Suite Administrator"
resource "btp_subaccount_role_collection_assignment" "api_man_rolecollection_ass2" {
  for_each             = toset(var.api_man_admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "APIPortal.Guest"
  user_name            = each.value
  //depends_on           = [btp_subaccount_role_collection.Integration_Suite_Admin, btp_subaccount_subscription.integrationsuite, btp_subaccount_entitlement.integrationsuite]
}
# Assign users to the role collection "Integration Suite Administrator"
resource "btp_subaccount_role_collection_assignment" "api_man_rolecollection_ass3" {
  for_each             = toset(var.api_man_admins)
  subaccount_id        = var.subaccount_id
  role_collection_name = "APIPortal.Service.CatalogIntegration"
  user_name            = each.value
  //depends_on           = [btp_subaccount_role_collection.Integration_Suite_Admin, btp_subaccount_subscription.integrationsuite, btp_subaccount_entitlement.integrationsuite]
}

*/




//Add entitlement for API Management, API Portal 
//Service technical name -  apimanagement-apiportal
//Plan - apiportal-apiaccess
resource "btp_subaccount_entitlement" "api_management_entl" {
  subaccount_id = var.subaccount_id
  service_name  = "apimanagement-apiportal"
  plan_name     = "apiportal-apiaccess"
  #amount        = 1                                 #cant set quota for this entitlement
}

//Find the API Management, API portal service offering
data "cloudfoundry_service_plans" "api_management_plan" {
  name                  = "apiportal-apiaccess"
  service_offering_name = "apimanagement-apiportal"
  depends_on = [ btp_subaccount_entitlement.api_management_entl ]
}

/*
output "pi_runtime_service_plans" {
  value = data.cloudfoundry_service_plans.pi_runtime_plan.service_plans
}
*/

locals {
  service_p = [for plans in data.cloudfoundry_service_plans.api_management_plan.service_plans : plans if plans.name == "apiportal-apiaccess"][0]
}

/*
output "service_p-id" {
  value = local.service_p.id
}
*/


//Create the API Management, API Portal
resource  "cloudfoundry_service_instance" "api_management_instance" {
  name  = "${var.subaccount_name}-api_man"
  type  = "managed"
  space = data.cloudfoundry_space.space.id
  service_plan = local.service_p.id //data.cloudfoundry_service_plans.pi_runtime_plan.service_plans[local.myIndex].id 
    parameters = <<EOT
    {
        "role": "APIPortal.Administrator"
    }
    EOT
}

data "cloudfoundry_service_instance" "api_instance" {
  name  = "${var.subaccount_name}-api_man"
  space = data.cloudfoundry_space.space.id
  depends_on = [ cloudfoundry_service_instance.api_management_instance ]
}

resource "cloudfoundry_service_credential_binding" "scb1" {
  type             = "key"
  name             = "api_service_key"
  service_instance = data.cloudfoundry_service_instance.api_instance.id
}
