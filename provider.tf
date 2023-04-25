terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=3.0.0"
    }
  }
}   

provider "azurerm" {
    features {}

    tenant_id = "a4302eba-73ff-49f5-b765-3c2ca31db754"  
}