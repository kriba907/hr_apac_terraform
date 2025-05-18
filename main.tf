#------------------------------------------------------------------------------------#
# Governance Modal - Landscape Strategy
#------------------------------------------------------------------------------------#
# Global Account
# 1. Every Global account should have atleast 2 Administrators
#
# Subaccount
# 1. For a staged Developement, create atleast 3 Subaccounts per MF per Workstream
# 2. Naming Convention - <<Work Stream>>_<<Member Firm>>_<<System Identifier>>
# 3. Subdomain should contain only lower case characters
# 4. Subdomain for the subaccount should be a uuid
#
# Entitlements
# 1. The Global Account administrator should provision Entitlements to Subaccounts
#
# Service Subscriptions
# 1. Global Services Catalogue, a document that has info on all the Services that a
#    Global Account is Entitled to, should be maintained
# 2. Local Services Catalogue, a document that has info on all the Services plans 
#    that are assigned to the Subaccount, should be maintained
# 3. The Subaccount Administrator should create Service instances or subscriptions
# 4. All Global Account Administrators should be Subaccount Administrators
#
# Role Collections
# 1. Every Service Subscription or Instance must have atleast 2 Role Colelctions
#    - Service Administrator and Service Developer
# 2. Users Onboarding should be performed using the User Onboarding document
#

resource "random_string" "dev-random" {
  length           = 8
  special          = false
  upper            = false
  #override_special = "/@£$"
}
resource "random_string" "test-random" {
  length           = 8
  special          = false
  upper            = false
  #override_special = "/@£$"
}
resource "random_string" "prod-random" {
  length           = 8
  special          = false
  upper            = false
  #override_special = "/@£$"
}

#------------------------------------------------------------------------------------#
# Directory, Subaccounts, Subaccount Admin role assignment, Cloud Foundry Env
#------------------------------------------------------------------------------------#
# Create a parent directory without features enabled
resource "btp_directory" "hr_directory" {
  name        = "HR"
  description = "Human Resource Directory"
}

# Create the subaccount
# Subdomain: hr-ap-dev (naming convention)
# Tenant ID: 8ee70929-cfdc-4d96-ad63-a2ffabc66d02 (random uuid)
# Subaccount ID: 8ee70929-cfdc-4d96-ad63-a2ffabc66d02 (this is the same as Tenant ID)
resource "btp_subaccount" "sa_dev" {
  #for_each = { for dc in data.btp_regions.all.values : dc.region => dc if dc.environment == "cloudfoundry" && dc.iaas_provider == "AZURE" }
  name      = var.subaccount_name_dev
  subdomain = "${var.subaccount_name_dev}-${random_string.dev-random.result}"                   # this could be a unique number
  region    = lower(var.region)
  parent_id = btp_directory.hr_directory.id
}

# Assign users to the role collection "Subaccount Administrator"
resource "btp_subaccount_role_collection_assignment" "Subaccount_Administrator_Dev" {
  for_each             = toset(var.subaccount_admins)
  subaccount_id        = btp_subaccount.sa_dev.id
  role_collection_name = "Subaccount Administrator"
  user_name            = each.value
  depends_on = [ btp_subaccount.sa_dev ]
}

# creates a cloud foundry environment in a given account
resource "btp_subaccount_environment_instance" "cf_dev" {
  subaccount_id    = btp_subaccount.sa_dev.id
  name             = "${btp_subaccount.sa_dev.name}-cf"
  environment_type = "cloudfoundry"
  service_name     = "cloudfoundry"
  plan_name        = "standard"
  # ATTENTION: some regions offer multiple environments of a kind and you must explicitly select the target environment in which
  # the instance shall be created using the parameter landscape label. 
  # available environments can be looked up using the btp_subaccount_environments datasource
  parameters = jsonencode({
    instance_name = "${btp_subaccount.sa_dev.name}-cf"
  })
  depends_on = [ btp_subaccount.sa_dev ]
}


resource "btp_subaccount" "sa_test" {
  name      = var.subaccount_name_test
  subdomain = "${var.subaccount_name_test}-${random_string.test-random.result}"
  region    = lower(var.region)
  parent_id = btp_directory.hr_directory.id
}

# Assign users to the role collection "Subaccount Administrator_Test"
resource "btp_subaccount_role_collection_assignment" "Subaccount_Administrator" {
  for_each             = toset(var.subaccount_admins)
  subaccount_id        = btp_subaccount.sa_test.id
  role_collection_name = "Subaccount Administrator"
  user_name            = each.value
  depends_on = [ btp_subaccount.sa_test ]
}

resource "btp_subaccount_environment_instance" "cf_test" {
  subaccount_id    = btp_subaccount.sa_test.id
  name             = "${btp_subaccount.sa_test.name}-cf"
  environment_type = "cloudfoundry"
  service_name     = "cloudfoundry"
  plan_name        = "standard"
  # ATTENTION: some regions offer multiple environments of a kind and you must explicitly select the target environment in which
  # the instance shall be created using the parameter landscape label. 
  # available environments can be looked up using the btp_subaccount_environments datasource
  parameters = jsonencode({
    instance_name = "${btp_subaccount.sa_test.name}-cf"
  })
  depends_on = [ btp_subaccount.sa_test ]
}


resource "btp_subaccount" "sa_prod" {
  name      = var.subaccount_name_prod
  subdomain = "${var.subaccount_name_prod}-${random_string.prod-random.result}"   
  region    = lower(var.region)
  parent_id = btp_directory.hr_directory.id
}


# Assign users to the role collection "Subaccount Administrator"
resource "btp_subaccount_role_collection_assignment" "Subaccount_Administrator_Prod" {
  for_each             = toset(var.subaccount_admins)
  subaccount_id        = btp_subaccount.sa_prod.id
  role_collection_name = "Subaccount Administrator"
  user_name            = each.value
  depends_on = [ btp_subaccount.sa_prod ]
}

# creates a cloud foundry environment in a given account
resource "btp_subaccount_environment_instance" "cf_prod" {
  subaccount_id    = btp_subaccount.sa_prod.id
  name             = "${btp_subaccount.sa_prod.name}-cf"
  environment_type = "cloudfoundry"
  service_name     = "cloudfoundry"
  plan_name        = "standard"
  # ATTENTION: some regions offer multiple environments of a kind and you must explicitly select the target environment in which
  # the instance shall be created using the parameter landscape label. 
  # available environments can be looked up using the btp_subaccount_environments datasource
  parameters = jsonencode({
    instance_name = "${btp_subaccount.sa_prod.name}-cf"
  })
  depends_on = [ btp_subaccount.sa_prod ]
}


#------------------------------------------------------------------------------------#
# CF Org space, CF Role assignment
#------------------------------------------------------------------------------------#
//Once the CF environment is created, the ord name and org ID will be created
# Set up cloud foundry
module "cloud_foundry_dev" {
  #Path to the local file directory 
  source = "./modules/cloud_foundry/"
  subaccount_id = btp_subaccount.sa_dev.id
  org_name = "${btp_subaccount.sa_dev.name}-cf"
  org_Id = btp_subaccount_environment_instance.cf_dev.id
  cf_space_admins = var.cf_space_admins
  subaccount_admins = var.subaccount_admins
  depends_on = [ btp_subaccount_environment_instance.cf_dev ]
}

//Once the CF environment is created, the ord name and org ID will be created
# Set up cloud foundry
module "cloud_foundry_test" {
  #Path to the local file directory 
  source = "./modules/cloud_foundry/"
  subaccount_id = btp_subaccount.sa_test.id
  org_name = "${btp_subaccount.sa_test.name}-cf"
  org_Id = btp_subaccount_environment_instance.cf_test.id
  cf_space_admins = var.cf_space_admins
  subaccount_admins = var.subaccount_admins
  depends_on = [ btp_subaccount_environment_instance.cf_test ]
}

//Once the CF environment is created, the org name and org ID will be created
# Set up cloud foundry
module "cloud_foundry_prod" {
  #Path to the local file directory 
  source = "./modules/cloud_foundry/"
  subaccount_id = btp_subaccount.sa_prod.id
  org_name = "${btp_subaccount.sa_prod.name}-cf"
  org_Id = btp_subaccount_environment_instance.cf_prod.id
  cf_space_admins = var.cf_space_admins
  subaccount_admins = var.subaccount_admins
  depends_on = [ btp_subaccount_environment_instance.cf_prod ]
}


#------------------------------------------------------------------------------------#
# Integration Suite
#------------------------------------------------------------------------------------#
module "integrationsuite-dev" {
  #Path to the local file directory 
  source = "./modules/integration_suite"
  subaccount_id = btp_subaccount.sa_dev.id
  subaccount_name = btp_subaccount.sa_dev.name
  org_name = "${btp_subaccount.sa_dev.name}-cf"
  integration_suite_admins = var.integration_suite_admins
  subaccount_admins = var.subaccount_admins
  cf_space_admins = var.cf_space_admins
  depends_on = [ btp_subaccount.sa_dev ]
}

module "integrationsuite-test" {
  #Path to the local file directory 
  source = "./modules/integration_suite"
  subaccount_id = btp_subaccount.sa_test.id
  subaccount_name = btp_subaccount.sa_test.name
  org_name = "${btp_subaccount.sa_test.name}-cf"
  integration_suite_admins = var.integration_suite_admins
  subaccount_admins = var.subaccount_admins
  cf_space_admins = var.cf_space_admins
  depends_on = [ btp_subaccount.sa_test ]
}

module "integrationsuite-prod" {
  #Path to the local file directory 
  source = "./modules/integration_suite"
  subaccount_id = btp_subaccount.sa_prod.id
  subaccount_name = btp_subaccount.sa_prod.name
  org_name = "${btp_subaccount.sa_prod.name}-cf"
  integration_suite_admins = var.integration_suite_admins
  subaccount_admins = var.subaccount_admins
  cf_space_admins = var.cf_space_admins
  depends_on = [ btp_subaccount.sa_prod ]
}



//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//At this point - add the Cloud Integration and API management capabilities  
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------



#------------------------------------------------------------------------------------#
# Process Integration Runtime
#------------------------------------------------------------------------------------#
module "pir-dev" {
  #Path to the local file directory 
  source = "./modules/process_integration_runtime"
  subaccount_id = btp_subaccount.sa_dev.id
  subaccount_name = btp_subaccount.sa_dev.name
  org_name = "${btp_subaccount.sa_dev.name}-cf"
  //depends_on = [ btp_subaccount.sa_dev ]
  //depends_on    = [ btp_subaccount_subscription.integrationsuite ]
}

module "pir-test" {
  #Path to the local file directory 
  source = "./modules/process_integration_runtime"
  subaccount_id = btp_subaccount.sa_test.id
  subaccount_name = btp_subaccount.sa_test.name
  org_name = "${btp_subaccount.sa_test.name}-cf"
  //depends_on = [ btp_subaccount.sa_dev ]
  //depends_on    = [ btp_subaccount_subscription.integrationsuite ]
}

module "pir-prod" {
  #Path to the local file directory 
  source = "./modules/process_integration_runtime"
  subaccount_id = btp_subaccount.sa_prod.id
  subaccount_name = btp_subaccount.sa_prod.name
  org_name = "${btp_subaccount.sa_prod.name}-cf"
  //depends_on = [ btp_subaccount.sa_dev ]
  //depends_on    = [ btp_subaccount_subscription.integrationsuite ]
}


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//Remember - Activate the API management portal
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

#------------------------------------------------------------------------------------#
# API Management, API Portal
#------------------------------------------------------------------------------------#
module "api_management_dev" {
  #Path to the local file directory 
  source = "./modules/api_management/"
  subaccount_id = btp_subaccount.sa_dev.id
  subaccount_name = btp_subaccount.sa_dev.name
  org_name = "${btp_subaccount.sa_dev.name}-cf"
  org_Id = btp_subaccount_environment_instance.cf_dev.id
  api_man_admins = var.api_man_admins
  depends_on = [ btp_subaccount_environment_instance.cf_dev ]
}

module "api_management_test" {
  #Path to the local file directory 
  source = "./modules/api_management/"
  subaccount_id = btp_subaccount.sa_test.id
  subaccount_name = btp_subaccount.sa_test.name
  org_name = "${btp_subaccount.sa_test.name}-cf"
  org_Id = btp_subaccount_environment_instance.cf_test.id
  api_man_admins = var.api_man_admins
  depends_on = [ btp_subaccount_environment_instance.cf_test ]
}

module "api_management_prod" {
  #Path to the local file directory 
  source = "./modules/api_management/"
  subaccount_id = btp_subaccount.sa_prod.id
  subaccount_name = btp_subaccount.sa_prod.name
  org_name = "${btp_subaccount.sa_prod.name}-cf"
  org_Id = btp_subaccount_environment_instance.cf_prod.id
  api_man_admins = var.api_man_admins
  depends_on = [ btp_subaccount_environment_instance.cf_prod ]
}


/*
#------------------------------------------------------------------------------------#
# Set up Entitlements, service subscription and Role Collections
#------------------------------------------------------------------------------------#
# A module is a container for multiple resources that are used together
module "build_code" {
  #Path to the local file directory 
  source = "./modules/build_code/"
  subaccount_id = btp_subaccount.sa_dev.id
  application_studio_admins             = var.application_studio_admins
  application_studio_developers         = var.application_studio_developers
  application_studio_extension_deployer = var.application_studio_extension_deployer
  build_code_admins     = var.build_code_admins
  build_code_developers = var.build_code_developers
}

#------------------------------------------------------------------------------------#
# Set up Entitlements, service subscription and Role Collections
#------------------------------------------------------------------------------------#
module "build_process_automation" {
  source = "./modules/build_process_automation"
  subaccount_id = btp_subaccount.sa_dev.id
  process_automation_admins       = var.process_automation_admins
  process_automation_developers   = var.process_automation_developers
  process_automation_participants = var.process_automation_participants
}


#------------------------------------------------------------------------------------#
# Set up Entitlements, service subscription and Role Collections
#------------------------------------------------------------------------------------#
# A module is a container for multiple resources that are used together
module "integrationsuite-trial" {
  #Path to the local file directory 
  source = "./modules/integration_suite"
  subaccount_id = btp_subaccount.sa_dev.id
  integration_suite_admins = var.integration_suite_admins
}
*/
