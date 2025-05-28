terraform {
  backend "gcs" {
    bucket = "salma-terraform-backend"
    prefix = "terraform/state"
  }
}

