terraform {
  cloud {
    organization = "localtech-terraform"

    workspaces {
      name = "app-eks-vpc"
    }
  }
}