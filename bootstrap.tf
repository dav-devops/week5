# Step 1 — Bootstrap the remote state infrastructure
# Use the local backend temporarily to create your S3 bucket and related resources, and run
#terraform init
#terraform apply
# This creates your S3 bucket, versioning, encryption, etc.
# Step 2 — Comment out the local backend
# Once the S3 bucket exists, comment out the backend "local" block in bootstrap.tf:
# Step 3 — Add your remote backend config
# In your main configuration (usually backend.tf), define the new backend
# Step 4 — Initialize and migrate state
# Now, re-initialize Terraform to migrate the local state into S3:
#terraform init -migrate-state
# Step 5 — Verify
# Check that your state is now remote:


terraform {
  backend "local" {} # use local backend to create remote state infra
}


module "remote_state" {
  source               = "./modules/remote-state"
  bucket_name          = "hotelapp-terraform-remote-state"
  region               = "eu-north-1"
  environment          = "dev"
  enable_object_lock   = true
  encryption_algorithm = "AES256"
  tags = {
    Project   = "BluebirdHotelApp"
    ManagedBy = "Terraform"
  }
}
