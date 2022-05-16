terraform {
  cloud {
    organization = "localtech-terraform"

    workspaces {
      name = "eks-with-work-nodes"
    }
  }
}