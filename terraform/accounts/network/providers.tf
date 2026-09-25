provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project   = var.project_name
      Account   = "network"
      Pattern   = var.outbound_pattern
      ManagedBy = "terraform"
    }
  }
}
