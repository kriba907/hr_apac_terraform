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
  backend "remote" {
    organization = ""
    workspaces {
      name = ""
    }
  }
}

# Please checkout documentation on how best to authenticate against SAP BTP
# via the Terraform provider for SAP BTP
provider "btp" {
  #globalaccount = var.globalaccount
  globalaccount = var.globalaccount
  username      = var.username
  password      = var.password
}

provider "cloudfoundry" {
  api_url  = "https://api.cf.${var.region}.hana.ondemand.com"
  user     = var.username
  password = var.password
  //alias = "cloudfoundryprov"
}
