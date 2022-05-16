//provider
provider "aws" {
  region = "us-east-1"

}

#ECR Container Registry
resource "aws_ecr_repository" "ecrimage" {
  name                 = "uberapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}