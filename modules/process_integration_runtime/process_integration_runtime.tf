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

resource "btp_subaccount_entitlement" "pir_entl" {
  subaccount_id = var.subaccount_id
  service_name  = "it-rt"
  plan_name     = "api"
  #amount        = 1                                 #cant set quota for this entitlement
}


//Get the org details
data "cloudfoundry_org" "org" {
  name = var.org_name
}

data "cloudfoundry_space" "space"{
  name      = "dev-space"
  org       = data.cloudfoundry_org.org.id
  //depends_on = [ cloudfoundry_space.space ]
}

//Service technical name - it-rt
//Plan - api
//Find the Process Integration service offering
data "cloudfoundry_service_plans" "pi_runtime_plan" {
  name                  = "api"
  service_offering_name = "it-rt"
  depends_on = [ btp_subaccount_entitlement.pir_entl ]
}


output "pi_runtime_service_plans" {
  value = data.cloudfoundry_service_plans.pi_runtime_plan.service_plans
}

//Service PLan ID is a UUID
//name             = "integration-flow"
//name             = "api"

locals {
  service_p = [for plans in data.cloudfoundry_service_plans.pi_runtime_plan.service_plans : plans if plans.name == "api"][0]
  //plan = contains(local.service_p.name,"api")
  //myIndex = index(local.service_p.*.name,"api")
}

output "service_p-id" {
  value = local.service_p.id
}

//Create the Process Integration Runtime Instance
resource  "cloudfoundry_service_instance" "pi_runtime" {
  name  = "${var.subaccount_name}-pi_runtime"
  type  = "managed"
  space = data.cloudfoundry_space.space.id
  service_plan = local.service_p.id //data.cloudfoundry_service_plans.pi_runtime_plan.service_plans[local.myIndex].id 
    parameters = <<EOT
    {
      "roles": [
          "AccessAllAccessPoliciesArtifacts",
          "AccessPoliciesEdit",
          "AccessPoliciesRead",
          "AuthGroup_Administrator",
          "AuthGroup_BusinessExpert",
          "AuthGroup_ContentPublisher",
          "AuthGroup_IntegrationDeveloper",
          "AuthGroup_TenantPartnerDirectoryConfigurator",
          "CatalogPackageArtifactsRead",
          "CatalogPackagesRead",
          "CatalogPackagesCopy",
          "CredentialsEdit",
          "CredentialsRead",
          "DataArchivingActivate",
          "DataArchivingRead",
          "DataStorePayloadsRead",
          "DataStoresAndQueuesConfig",
          "DataStoresAndQueuesDelete",
          "DataStoresAndQueuesRead",
          "ExternalLoggingActivate",
          "ExternalLoggingActivationRead",
          "MessagePayloadsRead",
          "MessageProcessingLocksDelete",
          "MessageProcessingLocksRead",
          "MonitoringArtifactsDeploy",
          "MonitoringDataRead",
          "SecurityMaterialDownload",
          "SecurityMaterialEdit",
          "TraceConfigurationEdit",
          "TraceConfigurationRead",
          "WorkspaceArtifactLocksDelete",
          "WorkspaceArtifactLocksRead",
          "WorkspaceArtifactsDeploy",
          "WorkspacePackagesConfigure",
          "WorkspacePackagesEdit",
          "WorkspacePackagesRead",
          "WorkspacePackagesTransport"
      ],
      "grant-types": [
          "client_credentials"
      ],
      "redirect-uris": [],
      "token-validity": 43200
    }
    EOT
}


data "cloudfoundry_service_instance" "service_instance" {
  name  = "${var.subaccount_name}-pi_runtime"
  space = data.cloudfoundry_space.space.id
  depends_on = [ cloudfoundry_service_instance.pi_runtime ]
}

resource "cloudfoundry_service_credential_binding" "scb1" {
  type             = "key"
  name             = "service_key"
  service_instance = data.cloudfoundry_service_instance.service_instance.id
}


/*
output "guid" {
  value = data.cloudfoundry_service_instance.svc.id
}
*/
