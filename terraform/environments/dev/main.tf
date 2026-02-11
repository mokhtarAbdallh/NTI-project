module "vpc" {
  source = "../../modules/vpc"
  cidr = "10.0.0.0/16"
}

module "subnets" {
  source = "../../modules/subnets"
  vpc_id = module.vpc.vpc_id
  azs = ["us-east-1a","us-east-1b","us-east-1c"]
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24","10.0.12.0/24","10.0.13.0/24"]
}

module "routes" {
  source = "../../modules/routes"
  vpc_id = module.vpc.vpc_id
  public_subnets  = module.subnets.public_subnets
  private_subnets = module.subnets.private_subnets
}

 
module "security" {
  source = "../../modules/security"
vpc_id = module.vpc.vpc_id
}
 
module "iam" {
  source = "../../modules/iam"
}

module "eks" {
  source = "../../modules/eks"
  name = "dev-eks"
  role_arn = module.iam.cluster_role_arn
 subnets = module.subnets.private_subnets
  sg_id = module.security.eks_sg_id
}

module "nodegroup" {
  source = "../../modules/nodegroup"
  cluster_name = module.eks.cluster_name
  node_role_arn = module.iam.node_role_arn
  subnets = module.subnets.private_subnets
}

module "rds" {
  source = "../../modules/rds"
  db_name = "microdb"
  db_user = "microadmin"
  db_password = "StrongPassword123!"
 subnets = module.subnets.private_subnets
vpc_id  = module.vpc.vpc_id
}
module "secrets" {
  source = "../../modules/secrets"

  name        = "micro-db-secret-dev"
  db_username = "microadmin"
  db_password = var.db_password
  db_name     = "microdb"
  db_host     = module.rds.endpoint
}

module "ecr_backend" {
  source = "../../modules/ecr"
  name   = "micro-backend"
}

module "ecr_frontend" {
  source = "../../modules/ecr"
  name   = "micro-frontend"
}
module "argocd" {
  source = "../../modules/argocd"

  depends_on = [
    module.eks
  ]
}
