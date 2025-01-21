terraform {
  required_version = "~> 1.8.4"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.21"
    }
  }

  backend "s3" {
    bucket = "demo512"
    key    = "terraform/snapshot/state.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "aws_lab"
  # profile = "default"
  region  = "us-east-2"
}


# all the subnets in the aws region
data "aws_subnets" "all_subnets" {
	provider = aws.aws_lab
    filter {
    name   = "tag:Name"
    values = ["${var.env}-abc-subnet-1-pub"]
  }
}

output "ami_id" {
  value = data.aws_ami.example.id
}
