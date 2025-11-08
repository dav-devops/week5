module "network" {
  source                    = "./modules/network"

  vpc_name                  = var.vpc_name
  cidr_block_vpc            = var.cidr_block_vpc
  map_public_ip             = var.map_public_ip
}

module "security" {
  source                    = "./modules/security"
  vpc_id                    = module.network.vpc_id
  ingress_rules             = var.ingress_rules
  environment               = var.environment
}

module "alb" {
  source                    = "./modules/alb"
  vpc_id                    = module.network.vpc_id
  subnets                   = module.network.public_subnet_ids
  alb_sg_id                 = module.security.alb_sg_id
}

module "compute" {
  source                    = "./modules/compute"
  subnet_ids                = module.network.public_subnet_ids
  target_group_arn          = module.alb.target_group_arn
  alb_sg_id                 = module.security.alb_sg_id
  asg_sg_id                 = module.security.asg_sg_id
  iam_instance_profile_name = module.security.iam_instance_profile_name

}