module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}
module "subnet" {
  source = "./modules/subnet"
  subnet_cidr = "10.0.1.0/24"
  vpc_id = module.vpc.vpc_id
}
module "ec2" {
  source = "./modules/ec2"
  ami = "ami-0c293f3f676ec4f90"
  instance_type = "t2.micro"
  key_name = "kp_prac-20220304"
  subnet_id = module.subnet.subnet_id
}
