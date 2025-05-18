//Get the org details
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

data "cloudfoundry_org" "org" {
  provider = cloudfoundry
  name = var.org_name
}

//Create an Org Space
resource "cloudfoundry_space" "space" {
  name      = "dev-space"
  org       = data.cloudfoundry_org.org.id
  allow_ssh = "true"
  //labels    = { test : "pass", purpose : "prod" }
  depends_on = [ data.cloudfoundry_org.org ]
}

data "cloudfoundry_space" "space"{
  name      = "dev-space"
  org       = data.cloudfoundry_org.org.id
  depends_on = [ cloudfoundry_space.space ]
}

/*
organization_user
organization_auditor
organization_manager
organization_billing_manager
space_auditor
space_developer
space_manager
space_supporter
*/
//Add code to add the Roles
resource "cloudfoundry_space_role" "space_manager_role" {
  for_each = toset(var.cf_space_admins)
  username = each.value
  type     = "space_manager"
  space    = data.cloudfoundry_space.space.id
}
//Add code to add the Roles
resource "cloudfoundry_space_role" "space_developer_role" {
  for_each = toset(var.cf_space_admins)
  username = each.value
  type     = "space_developer"
  space    = data.cloudfoundry_space.space.id
}
//Add code to add the Roles
resource "cloudfoundry_space_role" "space_supporter_role" {
  for_each = toset(var.cf_space_admins)
  username = each.value
  type     = "space_supporter"
  space    = data.cloudfoundry_space.space.id
}
//Add code to add the Roles
resource "cloudfoundry_space_role" "space_auditor_role" {
  for_each = toset(var.cf_space_admins)
  username = each.value
  type     = "space_auditor"
  space    = data.cloudfoundry_space.space.id
}


