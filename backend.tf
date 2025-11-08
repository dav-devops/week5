/*
terraform {
  backend "s3" {
    bucket        = "hotelapp-terraform-remote-state"
    key           = "global/s3/terraform.tfstate"
    region        = "eu-north-1"
    encrypt       = true
    use_lockfile  = true
  }
}
*/