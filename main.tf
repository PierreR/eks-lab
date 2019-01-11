provider "aws" {
  region = "eu-central-1"
}

# Using these data sources allows the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "lab"
  worker_groups = [
    {
      asg_desired_capacity = 2
      instance_type        = "m4.large"
      subnets              = "${join(",", module.vpc.private_subnets)}"
    }
  ]
  tags = {
    Environment = "test"
  }
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "1.14.0"
  name               = "lab-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = "${merge(local.tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))}"
}

module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = "${local.cluster_name}"
  subnets           = ["${module.vpc.private_subnets}"]
  tags              = "${local.tags}"
  vpc_id            = "${module.vpc.vpc_id}"
  worker_groups     = "${local.worker_groups}"
}
